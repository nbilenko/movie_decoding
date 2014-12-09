function makeAVI(data, fname)
	aviobj = avifile(fname,'compression','None');
	fig=figure;
	for i=1:size(data, 1)
		for frame=1:size(data,2)
			imshow(squeeze(data(i, frame, :, :, :)/255))
			F = getframe(fig);
   			aviobj = addframe(aviobj,F);
		end
	end
	close(fig);
	aviobj = close(aviobj);