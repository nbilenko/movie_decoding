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
                if strcmp(opts.align, 'ssd')
                    [alignt,~,~] = pyramidAlign(align, alignTo);
                end
                if strcmp(opts.align, 'gradient')
                    toGrad = doGradient(alignTo,false);
                    grad = doGradient(align,false);
                    [~,xshift,yshift] = pyramidAlign(grad,toGrad);
                    alignt = circshift(align,[xshift,yshift]);
                end
                data.guesses(timepoint, guess, frame, :, :, :) = alignt;
            end
        end
    end
end