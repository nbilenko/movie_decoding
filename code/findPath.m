function data = findPath(data, opts)
% use dynamic programming to find the cheapest path through the possible
% frames (right now we don't weight based on the llh of the guess, but we could)

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
    data.cliporder = zeros(opts.nT,1);
    for i=[opts.nT:-1:2]
        [~,idxmin] = min(totalFlowCost(i,:));
        data.cliporder(i) = idxmin;
    end
    % for the first clip, we need to return to our info from pairwiseMeansMat
    matchingClips = find(data.pairwiseMeans(2,data.cliporder(2),:)==min(totalFlowCost(2,:)));
    data.cliporder(1) = matchingClips(1);
end