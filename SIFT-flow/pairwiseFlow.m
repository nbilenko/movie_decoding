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
    codei = sprintf('data%03d',i-1);
    codei1 = sprintf('data%03d',i);
    lastframes = ifs.lastframes.(codei);
    firstframes = ifs.firstframes.(codei1);
    oc1 = im2double(squeeze(ocs.lastframes.(codei)));
    oc2 = im2double(squeeze(ocs.firstframes.(codei1)));
    ocsift1 = mexDenseSIFT(oc1,cellsize,gridspacing);
    ocsift2 = mexDenseSIFT(oc2,cellsize,gridspacing);
    [ocvx,ocvy,ocenergylist]=SIFTflowc2f(ocsift1, ocsift2,SIFTflowpara);
    ocFlowAvg = mean(mean(ocvx))^2 + mean(mean(ocvy))^2;
    pairwiseMeans.(codei).ocFlow = ocFlowAvg;
    for gi1=[1:guesses]
        guessi1code = sprintf('guess%03d',gi1);
        guessi1 = im2double(squeeze(lastframes(gi1,:,:,:,:)));
        sifti = mexDenseSIFT(guessi1,cellsize,gridspacing);
        for gi2=[1:guesses]
            guessi2code = sprintf('guess%03d',gi2);
            guessi1 = im2double(squeeze(firstframes(gi2,:,:,:,:)));
            sifti2 = mexDenseSIFT(guessi1,cellsize,gridspacing);
            [vx,vy,energylist]=SIFTflowc2f(sifti,sifti2,SIFTflowpara);
            flowAvg = mean(mean(vx))^2 + mean(mean(vy))^2;
            pairwiseMeans.(codei).(guessi1code).(guessi2code) = flowAvg;
            pairwiseMeansMat(i,gi1,gi2) = flowAvg;
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
    desiredClip = clips(i);
    ffStack = ifs.firstframes.(timecode);
    lfStack = ifs.lastframes.(timecode);
    bigClipStack(i,1,:,:,:) = squeeze(ffStack(desiredClip,:,:,:,:));
    bigClipStack(i,2,:,:,:) = squeeze(lfStack(desiredClip,:,:,:,:));
end

for clip=[1:n]
    figure((clip-1)*2+1);imshow(squeeze(bigClipStack(clip,1,:,:,:)));
    figure((clip-1)*2+2);imshow(squeeze(bigClipStack(clip,2,:,:,:)));
end