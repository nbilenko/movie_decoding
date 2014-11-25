function scores = HOGToGroundTruth(code)
    function score = HOG(frame1,frame2)
        hog1 = extractHOGFeatures(frame1);
        hog2 = extractHOGFeatures(frame2);
        score = sum((hog1-hog2).^2);
    end
    
    [ifs,ocs] = loadAllData(code);
    
    scores = zeros(size(ifs,1),1);
 
    for frame=[1:size(ifs, 2)]
        of = im2double(squeeze(ocs(:, frame, :, :, :)));
        for guess=[1:size(ifs, 1)]
            guessf = im2double(squeeze(ifs(guess,frame,:,:,:)));
            guessDist = HOG(guessf, of);
            scores(guess) = scores(guess) + guessDist;
        end
    end
    
end