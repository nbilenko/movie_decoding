function makeMorphGIF(data, opts, fname)
	firstFrame = squeeze(data.morphs(1, 1, :, :, :))/255;
	[A,map] = rgb2ind(firstFrame,256); 
	imwrite(A,map,fname,'gif','LoopCount',Inf,'DelayTime',1/15);
	for frame=2:size(data.morphs, 2)
		fr = squeeze(data.morphs(1, frame, :, :, :))/255;
		[A,map] = rgb2ind(fr,256);
		imwrite(A,map,fname,'gif','WriteMode','append','DelayTime',1/15);
	end
	for clip=2:size(data.morphs, 1)
		for frame=1:size(data.morphs, 2)
			fr = squeeze(data.morphs(clip, frame, :, :, :))/255;
			[A,map] = rgb2ind(fr,256);
			imwrite(A,map,fname,'gif','WriteMode','append','DelayTime',1/15);
		end
	end
end