function data = findPath(data, opts)
% use dynamic programming to find the cheapest path through the possible
% frames (right now we don't weight based on the llh of the guess, but we could)

    REALBIG = 99999999999999999999;

    totalFlowCost = zeros(opts.nT, opts.nGchosen);
    % first, populate the transition matrix
    for timepoint=[2:opts.nT]
        costsToHere = squeeze(totalFlowCost(timepoint-1,:,:));
        for nextFrame=[1:opts.nGchosen]
            costToNextFrame = min(costsToHere+squeeze(data.pairwiseMeans(timepoint,nextFrame,:)).');
            totalFlowCost(timepoint,nextFrame) = costToNextFrame;
        end
    end
    
    % now to back up through the matrix    
    cpTotalFlowCost = totalFlowCost;
    data.cliporder = zeros(opts.nT,opts.nGPath);
    for i=[opts.nT:-1:2]
        for j=1:opts.nGPath
            [~,idxmin] = min(cpTotalFlowCost(i,:));
            data.cliporder(i,j) = idxmin;
            cpTotalFlowCost(i,idxmin) = REALBIG;
        end
    end
    
    % for the first clip, we need to return to our info from pairwiseMeansMat
    [~, matchingClips] = sort(squeeze(data.pairwiseMeans(2,data.cliporder(2,1),:) - min(totalFlowCost(2,:))));
    data.cliporder(1,:) = matchingClips(1:opts.nGPath);
end