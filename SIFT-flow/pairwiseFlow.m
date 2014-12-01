% from demo.m
cellsize=3;
gridspacing=1;

addpath(fullfile(pwd,'mexDenseSIFT'));
addpath(fullfile(pwd,'mexDiscreteFlow'));

SIFTflowpara.alpha=2*255;
SIFTflowpara.d=40*255;
SIFTflowpara.gamma=0.005*255;
SIFTflowpara.nlevels=4;
SIFTflowpara.wsize=2;
SIFTflowpara.topwsize=10;
SIFTflowpara.nTopIterations = 60;
SIFTflowpara.nIterations= 30;
% <end from demo.m>

SSD = false;
HOG = true;
MORPH = false;
SAVE_GIF = true;
SHOW_FIRST_AND_LAST_FRAMES = true;

timesteps = 3;
chooseFromHOG = 5;
chooseFromSSD = 5;
minMode = 'diff';

[ifs,ocs] = loadData(timesteps);

if HOG
    % do some HOG matching on the first and last frames
    for i=[1:timesteps]
        code = sprintf('data%03d',i);
        scores = HOGToGroundTruth(code);

        % now that we have scores, order the clips based on those
        [sorted,idxs] = sort(scores);

        % now keep the good ones, in order
        ifs.firstframes.(code) = ifs.firstframes.(code)(idxs(1:chooseFromHOG),:,:,:,:);
        ifs.lastframes.(code) = ifs.lastframes.(code)(idxs(1:chooseFromHOG),:,:,:,:);
    end
end

if SSD
    % do some SSDs on the first and last frames
    for i=[1:timesteps]
        code = sprintf('data%03d',i);
        firstframes = ifs.firstframes.(code);
        lastframes = ifs.lastframes.(code);
        clipff = im2double(squeeze(ocs.lastframes.(code)));
        cliplf = im2double(squeeze(ocs.firstframes.(code)));
        scores = SSDToGroundTruth(firstframes,lastframes,clipff,cliplf);

        % now that we have scores, order the clips based on those
        [sorted,idxs] = sort(scores);

        % now keep the good ones, in order
        ifs.firstframes.(code) = ifs.firstframes.(code)(idxs(1:chooseFromSSD),:,:,:,:);
        ifs.lastframes.(code) = ifs.lastframes.(code)(idxs(1:chooseFromSSD),:,:,:,:);
    end
end

SIFTguesses = size(ifs.firstframes.data001,1);
pairwiseMeans = struct;
pairwiseMeansMat = zeros(timesteps,SIFTguesses,SIFTguesses);

% do the big nasty SIFT bits
for i=[2:timesteps]
    code1 = sprintf('data%03d',i-1);
    code2 = sprintf('data%03d',i);
    lastframes = ifs.lastframes.(code1);
    firstframes = ifs.firstframes.(code2);
    oc1 = im2double(squeeze(ocs.lastframes.(code1)));
    oc2 = im2double(squeeze(ocs.firstframes.(code2)));
    ocsift1 = mexDenseSIFT(oc1,cellsize,gridspacing);
    ocsift2 = mexDenseSIFT(oc2,cellsize,gridspacing);
    [ocvx,ocvy,ocenergylist]=SIFTflowc2f(ocsift1, ocsift2,SIFTflowpara);
    ocFlowAvg = mean(mean(ocvx))^2 + mean(mean(ocvy))^2;
    pairwiseMeans.(code1).ocFlow = ocFlowAvg;
    for g1=[1:SIFTguesses]
        guess1code = sprintf('guess%03d',g1);
        guess1 = im2double(squeeze(lastframes(g1,:,:,:,:)));
        sifti = mexDenseSIFT(guess1,cellsize,gridspacing);
        for g2=[1:SIFTguesses]
            guess2code = sprintf('guess%03d',g2);
            guess1 = im2double(squeeze(firstframes(g2,:,:,:,:)));
            sifti2 = mexDenseSIFT(guess1,cellsize,gridspacing);
            [vx,vy,energylist]=SIFTflowc2f(sifti,sifti2,SIFTflowpara);
            if strcmp(minMode, 'diff')
                flowAvg = sum(sum((vx-ocvx)^2 + (vy-ocvy)^2));
            else
                flowAvg = mean(mean(vx))^2 + mean(mean(vy))^2;
            end
            pairwiseMeans.(code1).(guess1code).(guess2code) = flowAvg;
            pairwiseMeansMat(i,g1,g2) = flowAvg;
        end
    end
end

% use dynamic programming to find the cheapest path through the possible
% frames (right now we don't weight based on the llh of the guess, but we could)
totalFlowCost = zeros(timesteps,SIFTguesses);

% first, populate the transition matrix
for i=[2:timesteps]
    costsToHere = squeeze(totalFlowCost(i-1,:,:));
    for nextFrame=[1:SIFTguesses]
        costToNextFrame = min(costsToHere+squeeze(pairwiseMeansMat(i,nextFrame,:)).');
        totalFlowCost(i,nextFrame) = costToNextFrame;
    end
end

% now to back up through the matrix
clips = zeros(timesteps,1);
for i=[timesteps:-1:2]
    [~,idxmin] = min(totalFlowCost(i,:));
    clips(i) = idxmin;
end
% for the first clip, we need to return to our info from pairwiseMeansMat
clips(1) = find(pairwiseMeansMat(2,clips(2),:)==min(totalFlowCost(2,:)));

bigClipStack = zeros(timesteps,2,128,128,3);
for i=[1:timesteps]
    timecode = sprintf('data%03d',i);
    clipId = clips(i);
    ffStack = ifs.firstframes.(timecode);
    lfStack = ifs.lastframes.(timecode);
    bigClipStack(i,1,:,:,:) = squeeze(ffStack(clipId,:,:,:,:));
    bigClipStack(i,2,:,:,:) = squeeze(lfStack(clipId,:,:,:,:));
end

if MORPH
    % we now have a big clip stack.  we want to take the 8th frame (halfway
    % through) from each clip and morph the SIFT keypoints between it and the
    % previous and following clips, in APPEARANCE ONLY.

    % this means that we need to take the SIFT keypoints and find
    % correspondences, then triangulate, then morph.  fortunately, I believe we
    % can do this using the functions that came with the SIFT flow code!

    % the SIFT warping thing is probably going to be our friend here.  so what
    % we will have are a bunch of frames:
    % a8 a9 a10 a11 a12 a13 a14 a15 ... b1 b2 b3 b4 b5 b6 b7 b8
    % and the way we want to match them up is... a8 shape + b8 partial
    % appearance, a9 shape + b7 partial appearance, a10 shape + b6 partial
    % appearance, &c.?  or is there something else that we want to do..?    
    for ts=[1:timesteps]
        if(ts > 1)
            for frame=[1:8]
                curFrame = squeeze(bigClipStack(i,frame,:,:,:));
                morphFrame = squeeze(bigClipStack(i-1,16-frame,:,:,:));
                bigClipStack(i,frame,:,:,:) = SIFTMorphFrames(curFrame,morphFrame,frame/8,cellsize,gridspacing,SIFTflowpara);
            end
        end
        if(ts < timesteps - 1)
            for frame=[8:15]
                curFrame = squeeze(bigClipStack(i,frame,:,:,:));
                morphFrame = squeeze(bigClipStack(i+1,16-frame,:,:,:));
                bigClipStack(i,frame,:,:,:) = SIFTMorphFrames(curFrame,morphFrame,(16-frame)/8,cellsize,gridspacing,SIFTflowpara);
            end
        end
    end
end



if SAVE_GIF
    fname = 'out.gif';
    firstFrame = zeros(squeeze(bigClipStack(clip,1,:,:,:)));
    [A,map] = rgb2ind(firstFrame,256); 
    imwrite(A,map,fname,'gif','LoopCount',Inf,'DelayTime',1/15);
end

for clip=[1:timesteps]
    code = sprintf('data%03d',clip);
    if SHOW_FIRST_AND_LAST_FRAMES
        figure((clip-1)*4+1);imshow(squeeze(ocs.firstframes.(code)));
        title(sprintf('original clip first frame ts %d',clip));
        figure((clip-1)*4+2);imshow(squeeze(ocs.lastframes.(code)));
        title(sprintf('original clip last frame ts %d',clip));
        figure((clip-1)*4+3);imshow(squeeze(bigClipStack(clip,1,:,:,:))/255);
        title(sprintf('best guess first frame ts %d',clip));
        figure((clip-1)*4+4);imshow(squeeze(bigClipStack(clip,2,:,:,:))/255);
        title(sprintf('best guess last frame ts %d',clip));
    end
    if SAVE_GIF
        for frame=[1:15]
            fr = bigClipStack(clip,frame,:,:,:);
            [A,map] = rgb2ind(fr,256); 
            imwrite(A,map,fname,'gif','WriteMode','append','DelayTime',1/15);
        end
    end
end