function data = gradientize(data,opts)
    for timepoint=1:opts.nT
        for guess=1:opts.nG
            for frame=1:opts.nframes
                 data.guesses(timepoint, guess, frame, :, :, :) = doGradient(squeeze(data.guesses(timepoint, guess, frame, :, :, :)),opts.inverseGradient) * opts.bumpUpGradient;
            end
        end
    end
end