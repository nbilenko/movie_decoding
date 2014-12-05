function data = morphFrames(data, opts)

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

    % Tried this, but it doesn't really work (commented out) - the transitions between clips are more jarring.
    % Different implementation is only using the middle frames.
    % It's not really a movie, just a morph between frames... some of the timepoints look cool, but not all.

    data.morphs = zeros(size(squeeze(data.guesses(:, 1, :, :, :, :))));

    for timepoint=1:opts.nT
        if timepoint > 1
            for frame=[1:8]
                % curFrame = squeeze(data.guesses(timepoint, data.cliporder(timepoint), frame, :, :, :));
                % morphFrame = squeeze(data.guesses(timepoint-1, data.cliporder(timepoint-1), 16-frame, :, :, :));
                % data.morphs(timepoint,frame,:,:,:) = SIFTMorphFrames(curFrame,morphFrame,frame/8,opts.cellsize,opts.gridspacing,opts.SIFTflowpara);
                curFrame = squeeze(data.guesses(timepoint-1, data.cliporder(timepoint-1), 8, :, :, :));
                morphFrame = squeeze(data.guesses(timepoint, data.cliporder(timepoint), 8, :, :, :));
                data.morphs(timepoint,frame,:,:,:) = SIFTMorphFrames(curFrame,morphFrame, (7+frame)/15,opts.cellsize,opts.gridspacing,opts.SIFTflowpara);
            end
        end
        if timepoint < opts.nT - 1
            for frame=[8:15]
                % curFrame = squeeze(data.guesses(timepoint, data.cliporder(timepoint), frame, :, :, :));
                % morphFrame = squeeze(data.guesses(timepoint+1, data.cliporder(timepoint+1), 16-frame, :, :, :));
                % data.morphs(timepoint,frame,:,:,:) = SIFTMorphFrames(curFrame,morphFrame,(16-frame)/8,opts.cellsize,opts.gridspacing,opts.SIFTflowpara);
                curFrame = squeeze(data.guesses(timepoint, data.cliporder(timepoint), 8, :, :, :));
                morphFrame = squeeze(data.guesses(timepoint+1, data.cliporder(timepoint+1), 8, :, :, :));
                data.morphs(timepoint,frame,:,:,:) = SIFTMorphFrames(curFrame,morphFrame,(frame-8)/15,opts.cellsize,opts.gridspacing,opts.SIFTflowpara);
            end
        end
    end
end