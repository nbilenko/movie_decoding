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

n = 3;
guesses = 3;

[ifs,ocs] = loadData(n);
pairwiseMeans = struct;
pairwiseMeansMat = zeros(n,guesses,guesses);

for i=[2:n]
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
    for g1=[1:guesses]
        guess1code = sprintf('guess%03d',g1);
        guess1 = im2double(squeeze(lastframes(g1,:,:,:,:)));
        sifti = mexDenseSIFT(guess1,cellsize,gridspacing);
        for g2=[1:guesses]
            guess2code = sprintf('guess%03d',g2);
            guess1 = im2double(squeeze(firstframes(g2,:,:,:,:)));
            sifti2 = mexDenseSIFT(guess1,cellsize,gridspacing);
            [vx,vy,energylist]=SIFTflowc2f(sifti,sifti2,SIFTflowpara);
            flowAvg = mean(mean(vx))^2 + mean(mean(vy))^2;
            pairwiseMeans.(code1).(guess1code).(guess2code) = flowAvg;
            pairwiseMeansMat(i,g1,g2) = flowAvg;
        end
    end
end

% use dynamic programming to find the cheapest path through the possible
% frames (right now we don't weight based on the llh of the guess, but we could)
totalFlowCost = zeros(n,guesses);

% first, populate the transition matrix
for i=[2:n]
    costsToHere = squeeze(totalFlowCost(i-1,:,:));
    for nextFrame=[1:guesses]
        costToNextFrame = min(costsToHere+squeeze(pairwiseMeansMat(i,nextFrame,:)).');
        totalFlowCost(i,nextFrame) = costToNextFrame;
    end
end

% now to back up through the matrix
clips = zeros(n,1);
for i=[n:-1:2]
    [~,idxmin] = min(totalFlowCost(i,:));
    clips(i) = idxmin;
end
% for the first clip, we need to return to our info from pairwiseMeansMat
clips(1) = find(pairwiseMeansMat(2,clips(2),:)==min(totalFlowCost(2,:)));

bigClipStack = zeros(n,2,128,128,3);
for i=[1:n]
    timecode = sprintf('data%03d',i);
    clipId = clips(i);
    ffStack = ifs.firstframes.(timecode);
    lfStack = ifs.lastframes.(timecode);
    bigClipStack(i,1,:,:,:) = squeeze(ffStack(clipId,:,:,:,:));
    bigClipStack(i,2,:,:,:) = squeeze(lfStack(clipId,:,:,:,:));
end

for clip=[1:n]
    figure((clip-1)*2+1);imshow(squeeze(bigClipStack(clip,1,:,:,:))/255);
    figure((clip-1)*2+2);imshow(squeeze(bigClipStack(clip,2,:,:,:))/255);
end