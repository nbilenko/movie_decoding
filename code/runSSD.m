function data = runSSD(data, opts)
    data.pairwiseMeans = zeros(opts.nT, opts.nGchosen, opts.nGchosen);
    for timepoint=2:opts.nT
        if strcmp(opts.minimize, 'diff')
            oframe1 = im2double(squeeze(data.ocs(timepoint-1, end, :, :, :)));
            oframe2 = im2double(squeeze(data.ocs(timepoint, 1, :, :, :)));
            oSSD = SSD(oframe1, oframe2);
        end
        for guess1=1:opts.nGchosen
            gidx1 = data.idxs(timepoint, guess1);
            frame1 = im2double(squeeze(data.guesses(timepoint-1, gidx1, end, :, :, :)));
            % sift1 = mexDenseSIFT(frame1,opts.cellsize,opts.gridspacing);
            if strcmp(opts.minimize, 'prev')
                oframe1 = im2double(squeeze(data.guesses(timepoint-1, gidx1, end-1, :, :, :)));
                oframe2 = im2double(squeeze(data.guesses(timepoint-1, gidx1, end, :, :, :)));
                oSSD = SSD(oframe1, oframe2);
            end
            for guess2=1:opts.nGchosen
                gidx2 = data.idxs(timepoint, guess2);
                frame2 = im2double(squeeze(data.guesses(timepoint, gidx2, 1, :, :, :)));
                nSSD = SSD(frame1, frame2);
                if strcmp(opts.minimize, 'diff') | strcmp(opts.minimize, 'prev')
                    flowAvg = abs(nSSD-oSSD);
                elseif strcmp(opts.minimize, 'avg')
                    flowAvg = nSSD;
                end
                data.pairwiseMeans(timepoint, guess1, guess2) = flowAvg;
            end
        end
    end
end