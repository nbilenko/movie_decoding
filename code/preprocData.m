function data = preprocData(data, opts)
	if strcmp(opts.preproc, 'none')
		data.idxs = repmat([1:opts.nG], opts.nT, 1);
	else
		scores = zeros(opts.nT, opts.nG);

		for timepoint=1:opts.nT
			if opts.gtruth
				frames1 = im2double(squeeze(data.ocs(timepoint, :, :, :, :)));
			end
			for guess=1:opts.nG
				if ~opts.gtruth
					for frame=1:size(data.guesses, 3)
	                    if frame == 1
	                        frames1(frame, :, :, :) = ones(opts.imsize(1), opts.imsize(2), opts.imsize(3));
	                    else
	    					frames1(frame, :, :, :) = im2double(squeeze(data.guesses(timepoint, guess, frame-1, :, :, :)));
	                    end
					end
				end
				frames2 = im2double(squeeze(data.guesses(timepoint, guess, :, :, :, :)));
				for frame=1:size(frames2, 1)
					if strcmp(opts.preproc, 'hog')
						guessDist = HOG(squeeze(frames1(frame, :, :, :)), squeeze(frames2(frame, :, :, :)));
					elseif strcmp(opts.preproc, 'ssd')
						guessDist = SSD(squeeze(frames1(frame, :, :, :)), squeeze(frames2(frame, :, :, :)));
					else
						disp('Preprocessing undefined for specified opts.preproc')
					end
					scores(timepoint, guess) = scores(timepoint, guess) + guessDist;
				end
			end
		end
		[sorted,idxs] = sort(scores, 2);
		data.idxs = idxs;
	end
end