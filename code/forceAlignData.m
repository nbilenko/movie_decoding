function data = forceAlignData(data, opts)
    if ~opts.forceAlign
        return;
    end
    
    % we want to force the alignment of all frames to the best guess (i.e.,
    % guess number 1)
    for timepoint=1:opts.nT
        for frame=1:opts.nframes
            alignTo = im2double(squeeze(data.guesses(timepoint, 1, frame, :, :, :)));
            for guess=2:opts.nG
                align = im2double(squeeze(data.guesses(timepoint, guess, frame, :, :, :)));
                alignt = pyramidAlign(align, alignTo);
                data.guesses(timepoint, guess, frame, :, :, :) = alignt;
            end
        end
    end
end