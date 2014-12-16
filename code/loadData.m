function [data, opts] = loadData(opts)
    if opts.firstlast
        nframes = 2;
    else
        nframes = opts.nframes;
    end
    if any(strcmp('tp_list', fieldnames(opts))) & ~isempty(opts.tp_list)
        opts.nT = length(opts.tp_list);
        opts.firstclip = opts.tp_list(1);
    else
        opts.tp_list = opts.firstclip:opts.firstclip-1+opts.nT;
    end


    data.guesses = zeros(opts.nT, opts.nG, nframes, opts.imsize(1), opts.imsize(2), opts.imsize(3));
    data.ocs = zeros(opts.nT, nframes, opts.imsize(1), opts.imsize(2), opts.imsize(3));
    data.llh = zeros(opts.nT, opts.nG);

    for i=1:opts.nT
        code = sprintf('data%03d',opts.tp_list(i));
        fname = strcat(code,'.hf5');
        floc = strcat(opts.dataFolder,fname);
        disp(floc);

        guessez = h5read(floc,'/guesses');
        guessez = permute(guessez, [5 4 3 2 1]);
        clipz = h5read(floc,'/clip');
        clipz = permute(clipz, [4 3 2 1]);
        llh = h5read(floc, '/llh');
        llh = llh(1:opts.nG, 1);
        data.llh(i, :) = (llh-min(llh))/(max(llh) - min(llh));

        if opts.firstlast
            data.guesses(i, :, 1, :, :, :) = squeeze(guessez(1:opts.nG, 1, :, :, :));
            data.guesses(i, :, 2, :, :, :) = squeeze(guessez(1:opts.nG, opts.nframes, :, :, :));
            data.ocs(i, 1, :, :, :) = squeeze(clipz(1, :, :, :));
            data.ocs(i, 2, :, :, :) = squeeze(clipz(opts.nframes, :, :, :));
        else
            data.guesses(i, :, :, :, :, :) = guessez(1:opts.nG,:,:,:,:);
            data.ocs(i, :, :, :, :) = clipz;
        end
    end
end