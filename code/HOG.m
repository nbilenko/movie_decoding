function score = HOG(frame1,frame2)
    hog1 = extractHOGFeatures(frame1);
    hog2 = extractHOGFeatures(frame2);
    score = sum((hog1-hog2).^2);
end