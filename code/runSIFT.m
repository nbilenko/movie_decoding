function data = runSIFT(data, opts)
    data.pairwiseMeans = zeros(opts.nT, opts.nGchosen, opts.nGchosen);
    for timepoint=2:opts.nT
        if strcmp(opts.minimize, 'diff')
            oframe1 = im2double(squeeze(data.ocs(timepoint-1, end, :, :, :)));
            oframe2 = im2double(squeeze(data.ocs(timepoint, 1, :, :, :)));
            osift1 = mexDenseSIFT(oframe1,opts.cellsize,opts.gridspacing);
            osift2 = mexDenseSIFT(oframe2,opts.cellsize,opts.gridspacing);
            [ocvx,ocvy,ocenergylist]=SIFTflowc2f(osift1, osift2,opts.SIFTflowpara);
        end
        for guess1=1:opts.nGchosen
            gidx1 = data.idxs(timepoint, guess1);
            frame1 = im2double(squeeze(data.guesses(timepoint-1, gidx1, end, :, :, :)));
            sift1 = mexDenseSIFT(frame1,opts.cellsize,opts.gridspacing);
            if strcmp(opts.minimize, 'prev')
                oframe1 = im2double(squeeze(data.guesses(timepoint-1, gidx1, end-1, :, :, :)));
                oframe2 = im2double(squeeze(data.guesses(timepoint-1, gidx1, end, :, :, :)));
                osift1 = mexDenseSIFT(oframe1,opts.cellsize,opts.gridspacing);
                osift2 = mexDenseSIFT(oframe2,opts.cellsize,opts.gridspacing);
                [ocvx,ocvy,ocenergylist]=SIFTflowc2f(osift1, osift2,opts.SIFTflowpara);
            end
            for guess2=1:opts.nGchosen
                gidx2 = data.idxs(timepoint, guess2);
                frame2 = im2double(squeeze(data.guesses(timepoint, gidx2, 1, :, :, :)));
                sift2 = mexDenseSIFT(frame2,opts.cellsize,opts.gridspacing);
                [vx,vy,energylist]=SIFTflowc2f(sift1,sift2,opts.SIFTflowpara);
                if strcmp(opts.minimize, 'diff') | strcmp(opts.minimize, 'prev')
                    flowAvg = sum(sum((vx-ocvx)^2 + (vy-ocvy)^2));
                elseif strcmp(opts.minimize, 'avg')
                    flowAvg = mean(mean(vx))^2 + mean(mean(vy))^2;
                end
                data.pairwiseMeans(timepoint, guess1, guess2) = flowAvg;
            end
        end
    end
end