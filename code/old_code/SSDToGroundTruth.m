function scores = SSDToGroundTruth(guessffs,guesslfs,clipff,cliplf)
    function score = SSD(frame1,frame2)
        score = sum(sum([dist2(squeeze(frame1(:,:,1)),squeeze(frame2(:,:,1))),...
                         dist2(squeeze(frame1(:,:,2)),squeeze(frame2(:,:,2))),...
                         dist2(squeeze(frame1(:,:,3)),squeeze(frame2(:,:,3)))]));
    end
    
    scores = zeros(size(guessffs,1),1);

    for i=[1:size(guessffs,1)]
        guessff = im2double(squeeze(guessffs(i,:,:,:,:)));
        guesslf = im2double(squeeze(guesslfs(i,:,:,:,:)));
        guessDist = SSD(guessff,clipff) + SSD(guesslf, cliplf);
        scores(i) = guessDist;
    end
    
end