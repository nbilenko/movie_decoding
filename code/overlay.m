function data = overlay(data, opts)
    flatOriginals = zeros(size(data.result));
    for time=1:opts.nT
        for frame=1:opts.nframes
            flatOriginals((time-1)*opts.nframes+frame,:,:,:) = data.ocs(time,frame,:,:,:);
        end
    end
    for frame=1:size(data.result, 1)
		guess = squeeze(data.result(frame, :, :, :));
        orig = doGradient(squeeze(flatOriginals(frame, :, :, :)),~opts.inverseGradient);
        % we'll just visualize the original in the red channel
        data.result(frame, :, :, 1) = orig(:,:,1) + guess(:,:,1);
        data.result(frame, :, :, 2:3) = guess(:,:,2:3);
	end
end