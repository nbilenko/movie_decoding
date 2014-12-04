function [ifs,ocs] = loadData(n)

    dataFolder = '../data/';

    ifs = struct;
    ifs.firstframes = struct;
    ifs.lastframes = struct;

    ocs = struct;
    ocs.firstframes = struct;
    ocs.lastframes = struct;

    for i=[1:n]
        code = sprintf('data%03d',i);
        fname = strcat(code,'.hf5');
        floc = strcat(dataFolder,fname);
        disp(floc);

        guessez = h5read(floc,'/guesses');
        guessez = permute(guessez, [5 4 3 2 1]);
        ffs = guessez(:,1,:,:,:);
        lfs = guessez(:,15,:,:,:);
        ifs.firstframes.(code) = ffs;
        ifs.lastframes.(code) = lfs;

        clipz = h5read(floc,'/clip');
        clipz = permute(clipz, [5 4 3 2 1]);
        ffs = clipz(:,1,:,:,:);
        lfs = clipz(:,15,:,:,:);
        ocs.firstframes.(code) = ffs;
        ocs.lastframes.(code) = lfs;
    end
    
end