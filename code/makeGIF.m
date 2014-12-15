function makeGIF(data, fname, fps)
	firstFrame = squeeze(data(1, :, :, :))/255;
	[A,map] = rgb2ind(firstFrame,256); 
	imwrite(A,map,fname,'gif','LoopCount',Inf,'DelayTime',1/fps);
	for clip=2:size(data, 1)
		fr = squeeze(data(clip, :, :, :))/255;
		[A,map] = rgb2ind(fr,256);
		imwrite(A,map,fname,'gif','WriteMode','append','DelayTime',1/fps);
	end
end