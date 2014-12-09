% Adding paths and defining SIFT-flow params
addpath(fullfile(pwd,'SIFT-flow'));
addpath(fullfile(pwd,'SIFT-flow/mexDenseSIFT'));
addpath(fullfile(pwd,'SIFT-flow/mexDiscreteFlow'));
%addpath(fullfile(pwd,'plot'));
opts = struct;
opts = defineSIFTPara(opts);

% Defining options
opts.dataFolder = '../data/';
opts.imsize = [128, 128, 3]; % frame size
opts.nT = 3; % number of timepoints
opts.nG = 100; % number of guesses loaded
opts.nframes = 15; % number of frames per timepoint
opts.nGchosen = 100; % number of guesses chosen in preprocessing
opts.preproc = 'none'; % type of preprocessing ('hog', 'ssd', or 'none')
opts.forceAlign = true;
opts.minimize = 'prev'; % metric to minimize ('diff' for difference between original clip and guess, 'avg' for average flow, 'prev' for comparing to previous frame difference)
opts.morph = false; % morph the clips using SIFT-flow?
opts.gif = true; % create gif at the end? If false, plots the first and last frames
opts.gtruth = false; % compare HOG to ground truth? (thinking this may not really be a good thing to do after all...)
opts.firstlast = false; % use first and last frames only or all frames?
opts.firstclip = 14; % what clip to start with?

% Load data
disp('loading data...');
data = loadData(opts); %6D guess matrix and 5D original clip matrix, first and last frames only
disp('done');

% Preprocess data
disp('preprocessing...');
data = preprocData(data, opts);
disp('done');

% Force alignment of data
disp('forcing alignment...');
data = forceAlignData(data, opts);
disp('done');

% Run SIFT-flow to compute amount of flow across all pairs of clips
disp('SIFT flow...');
data = runSIFT(data, opts);
disp('done');

% Use dynamic programming to find optimal clip ordering
disp('ordering clips...');
data = findPath(data, opts);
disp('done');

if opts.morph
	data = morphFrames(data, opts);
	makeMorphGIF(data, '../morph.gif');
end

if opts.gif
	makeGuessGIF(data, '../guess.gif');
end