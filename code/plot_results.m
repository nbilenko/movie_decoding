ssds = zeros(6, 165);
hogs = zeros(6, 165);
names = {'../data/llh.mat'; '../data/ssd.mat'; '../data/hog.mat'; '../data/llhsift.mat'; '../data/ssdsift.mat'; '../data/hogsift.mat'}

for i=1:6
	clear data
	load(char(names(i)))
	data.guesses = data.oguesses;
	opts.gradient = false;
	data = tempSmooth(data, opts);

    flatOriginals = zeros(size(data.result));
    for time=1:opts.nT
        for frame=1:opts.nframes
            flatOriginals((time-1)*opts.nframes+frame,:,:,:) = data.ocs(time,frame,:,:,:);
        end
    end

	for frame=1:size(data.result, 1)
		ssds(i, frame) = SSD(flatOriginals(frame, :, :, :), data.result(frame, :, :, :));
		hogs(i, frame) = HOG(flatOriginals(frame, :, :, :), data.result(frame, :, :, :));
	end
end

save('../data/results.mat', 'ssds', 'hogs', '-v7.3')

meanssd = mean(ssds', 1);
meanhog = mean(hogs', 1);

hogstd = std(hogs', 1);
ssdstd = std(ssds', 1);

figure; 
errorbar(1:6, meanssd, ssdssd); hold on;
errorbar(1:6, meanhog, ssdhog);
legend('SSD', 'HOG');
savefig('../data/results.png')