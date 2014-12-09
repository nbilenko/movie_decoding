function makeGIF(data, fname)
	firstFrame = squeeze(data(1, 1, :, :, :))/255;
	[A,map] = rgb2ind(firstFrame,256); 
	imwrite(A,map,fname,'gif','LoopCount',Inf,'DelayTime',1/size(data, 2));
	for frame=2:size(data, 2)
		fr = squeeze(data(1, frame, :, :, :))/255;
		[A,map] = rgb2ind(fr,256);
		imwrite(A,map,fname,'gif','WriteMode','append','DelayTime',1/size(data, 2));
	end
	for clip=2:size(data, 1)
		for frame=1:size(data, 2)
			fr = squeeze(data(clip, frame, :, :, :))/255;
			[A,map] = rgb2ind(fr,256);
			imwrite(A,map,fname,'gif','WriteMode','append','DelayTime',1/size(data, 2));
		end
	end
end