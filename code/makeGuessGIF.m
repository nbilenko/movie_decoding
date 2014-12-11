function makeGuessGIF(data, opts, fname)
	firstFrame = squeeze(sum(squeeze(data.guesses(1, data.cliporder(1,:), 1, :, :, :)))/opts.nGPath/255);
	[A,map] = rgb2ind(firstFrame,256); 
	imwrite(A,map,fname,'gif','LoopCount',Inf,'DelayTime',1/15);
	for frame=2:size(data.guesses, 3)
		fr = squeeze(sum(squeeze(data.guesses(1, data.cliporder(1,:), frame, :, :, :)))/opts.nGPath/255);
		[A,map] = rgb2ind(fr,256);
		imwrite(A,map,fname,'gif','WriteMode','append','DelayTime',1/15);
	end
	for clip=2:size(data.guesses, 1)
		for frame=1:size(data.guesses, 3)
			fr = squeeze(sum(squeeze(data.guesses(clip, data.cliporder(clip,:), frame, :, :, :)))/opts.nGPath/255);
			[A,map] = rgb2ind(fr,256);
			imwrite(A,map,fname,'gif','WriteMode','append','DelayTime',1/15);
		end
	end
end