function data = tempSmooth(data, opts)
	data.result = zeros(opts.nT*opts.nframes, opts.imsize(1), opts.imsize(2), opts.imsize(3));
	% First, sum over guesses and flatten the guess array:
	for clip=1:size(data.guesses, 1)
		for frame=1:size(data.guesses, 3)
			fr = squeeze(sum(squeeze(data.guesses(clip, data.cliporder(clip,:), frame, :, :, :)))/opts.nGPath/255);
			data.result((clip-1)*opts.nframes+frame, :, :, :) = fr;
		end
	end
	if opts.smoothWindow > 1
		data.result = reshape(smooth(reshape(data.result, opts.nT*opts.nframes, prod(opts.imsize)), opts.smoothWindow), opts.nT*opts.nframes, opts.imsize(1), opts.imsize(2), opts.imsize(3));
	end
end