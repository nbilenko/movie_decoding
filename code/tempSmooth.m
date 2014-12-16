function data = tempSmooth(data, opts)
	data.result = zeros(opts.nT*opts.nframes, opts.imsize(1), opts.imsize(2), opts.imsize(3));
	% First, sum over guesses and flatten the guess array:
	for clip=1:size(data.guesses, 1)
		for frame=1:size(data.guesses, 3)
			if opts.weightLLH
				fr = zeros(opts.imsize(1), opts.imsize(2), opts.imsize(3));
				llh = data.llh(clip, data.cliporder(clip,:));
				guesses = squeeze(data.guesses(clip, data.cliporder(clip,:), frame, :, :, :));
				for g=1:opts.nGPath
					fr = fr+llh(g).*squeeze(guesses(g, :, :, :))/opts.nGPath;
				end
			else
				fr = squeeze(sum(squeeze(data.guesses(clip, data.cliporder(clip,:), frame, :, :, :)))/opts.nGPath);
            end
            if opts.stretchGradient
                fr = (fr-min(fr(:,:,:))) ./ (max(fr(:,:,:)-min(fr(:,:,:))));
            end
			data.result((clip-1)*opts.nframes+frame, :, :, :) = fr;
		end
    end
	if opts.smoothWindow > 1
		data.result = reshape(smooth(reshape(data.result, opts.nT*opts.nframes, prod(opts.imsize)), opts.smoothWindow), opts.nT*opts.nframes, opts.imsize(1), opts.imsize(2), opts.imsize(3));
	end
end