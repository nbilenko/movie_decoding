function data = showims(data,timestep,idxs)
    data.guesses = data/255;
    frame = 1;
    zero = squeeze(data(timestep,idxs(1),frame,:,:,:));
    res = zero;
    for idx=2:size(idxs,2)
        i = idxs(idx);
        res = horzcat(res,squeeze(data(timestep,idxs(1,idx),frame,:,:,:)));
    end
    res = horzcat(res,1/6*squeeze(sum(data(timestep,idxs,frame,:,:,:))));
    figure();imshow(res);
end