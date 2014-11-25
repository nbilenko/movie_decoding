function [ifs,ocs] = loadAllData(code)

    dataFolder = '../data/';

    ifs = struct;

    ocs = struct;

    fname = strcat(code,'.hf5');
    floc = strcat(dataFolder,fname);
    disp(floc);

    guessez = h5read(floc,'/guesses');
    guessez = permute(guessez, [5 4 3 2 1]);
    ifs = guessez;

    clipz = h5read(floc,'/clip');
    clipz = permute(clipz, [5 4 3 2 1]);
    ocs = clipz;

end