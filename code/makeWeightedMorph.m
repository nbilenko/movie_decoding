function makeWeightedMorph(data, opts, fname)
	weighted_guesses = zeros(opts.nT, opts.nframes, opts.imsize(1), opts.imsize(2), opts.imsize(3));
	for i=1:opts.nT
		for f=1:opts.nframes
			for g=1:opts.nG
				weighted_guesses(i, f, :, :, :) = squeeze(weighted_guesses(i, f, :, :, :)) + squeeze(data.llh(i, g)).*squeeze(data.guesses(i, g, f, :, :, :));
				weighted_guesses(i, f, :, :, :) = 255*((weighted_guesses(i, f, :, :, :)-min(min(min((weighted_guesses(i, f, :, :, :))))))/(max(max(max(weighted_guesses(i, f, :, :, :)))) - min(min(min(weighted_guesses(i, f, :, :, :))))));
			end
		end
    end

	firstFrame = squeeze(weighted_guesses(1, 1, :, :, :))/255;
	[A,map] = rgb2ind(firstFrame,256); 
	imwrite(A,map,fname,'gif','LoopCount',Inf,'DelayTime',1/15);
	for frame=2:size(weighted_guesses, 2)
		fr = squeeze(weighted_guesses(1, frame, :, :, :))/255;
		[A,map] = rgb2ind(fr,256);
		imwrite(A,map,fname,'gif','WriteMode','append','DelayTime',1/15);
	end
	for clip=2:size(weighted_guesses, 1)
		for frame=1:size(weighted_guesses, 2)
			fr = squeeze(weighted_guesses(clip, frame, :, :, :))/255;
			[A,map] = rgb2ind(fr,256);
			imwrite(A,map,fname,'gif','WriteMode','append','DelayTime',1/15);
		end
	end
end