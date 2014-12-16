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
opts.firstlast = false; % use first and last frames only or all frames?
opts.firstclip = 15; % what clip to start with?

opts.nGchosen = 10; % number of guesses chosen in preprocessing
opts.preproc = 'hog'; % type of preprocessing ('hog', 'ssd', or 'none')
opts.gtruth = false; % compare HOG to ground truth? (thinking this may not really be a good thing to do after all...)

opts.forceAlign = true;
opts.align = 'gradient'; % 'ssd' or 'gradient' ; what do we want to align?

opts.flowMethod = 'ssd'; % How to compute flow? ('ssd' or 'sift')

opts.minimize = 'prev'; % metric to minimize in flow ('diff' for difference between original clip and guess, 'avg' for average flow, 'prev' for comparing to previous frame difference)
opts.nGPath = 5; % how many guesses are selected to be a part of the "path" thru the clips

opts.morph = false; % morph the clips using SIFT-flow?
opts.gif = true; % create gif at the end?

opts.gradient = true; % visualize in gradient domain? if false, use values.
opts.inverseGradient = false; % true: white on black. false: black on white.
opts.bumpUpGradient = 1; % 1.0: no scaling.  >1.0: more definition of edges.

opts.smooth = true; 
opts.smoothWindow = 5; % 1: no smoothing, just sum over gueeses
opts.weightLLH = true;

opts.overlay = true; % overlay the result on top of the input image? works best for gradients.

% Load data
disp('loading data...');
data = loadData(opts); %6D guess matrix and 5D original clip matrix, first and last frames only
disp('done');

% Preprocess data
disp('preprocessing...');
data = preprocData(data, opts);
disp('done');

% Force alignment of data
if opts.forceAlign
    disp('forcing alignment...');
    data = forceAlignData(data, opts);
    disp('done');
end

% Run flow to compute amount of flow across all pairs of clips
if strcmp(opts.flowMethod, 'sift')
	disp('SIFT flow...');
	data = runSIFT(data, opts);
	disp('done');
elseif strcmp(opts.flowMethod, 'ssd')
	disp('SSD flow...');
	data = runSSD(data, opts);
	disp('done');
elseif strcmp(opts.flowMethod, 'hog')
	disp('HOG flow...');
	data = runHOG(data, opts);
	disp('done');
end

% Use dynamic programming to find optimal clip ordering
disp('ordering clips...');
data = findPath(data, opts);
disp('done');

% move clips into the gradient domain for better visualization
if opts.gradient
    disp('converting to gradient domain...');
    data = gradientize(data,opts);
    disp('done');
end

if opts.smooth
	disp('smoothing temporally...');
	data = tempSmooth(data, opts);
	disp('done');
end

if opts.overlay
    disp('overlaying result with input');
    data = overlay(data, opts);
    disp('done');
end

% make a pretty visualization at the end
if opts.morph
	data = morphFrames(data, opts);
	makeMorphGIF(data, opts, '../morph.gif');
end

if opts.gif
	makeGIF(data.result, '../guess.gif', opts.nframes);
end