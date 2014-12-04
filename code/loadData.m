function data = loadData(opts)
    if opts.firstlast
        nframes = 2;
    else
        nframes = opts.nframes;
    end

    data.guesses = zeros(opts.nT, opts.nG, nframes, opts.imsize(1), opts.imsize(2), opts.imsize(3));
    data.ocs = zeros(opts.nT, nframes, opts.imsize(1), opts.imsize(2), opts.imsize(3));

    for i=[opts.firstclip:opts.firstclip-1+opts.nT]
        code = sprintf('data%03d',i);
        fname = strcat(code,'.hf5');
        floc = strcat(opts.dataFolder,fname);
        disp(floc);

        guessez = h5read(floc,'/guesses');
        guessez = permute(guessez, [5 4 3 2 1]);
        clipz = h5read(floc,'/clip');
        clipz = permute(clipz, [4 3 2 1]);

        if opts.firstlast
            data.guesses(i-opts.firstclip+1, :, 1, :, :, :) = squeeze(guessez(:, 1, :, :, :));
            data.guesses(i-opts.firstclip+1, :, 2, :, :, :) = squeeze(guessez(:, opts.nframes, :, :, :));
            data.ocs(i-opts.firstclip+1, 1, :, :, :) = squeeze(clipz(1, :, :, :));
            data.ocs(i-opts.firstclip+1, 2, :, :, :) = squeeze(clipz(opts.nframes, :, :, :));
        else
            data.guesses(i-opts.firstclip+1, :, :, :, :, :) = guessez;
            data.ocs(i-opts.firstclip+1, :, :, :, :) = clipz;
        end
    end
end