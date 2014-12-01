function morpht = SIFTMorphFrames(frame1,frame2,frac)
    f1SIFT = mexDenseSIFT(frame1,cellsize,gridspacing);
    f2SIFT = mexDenseSIFT(frame2,cellsize,gridspacing);
    [vx,vy,~]=SIFTflowc2f(f1SIFT,f2SIFT,SIFTflowpara);
    morphedFrame = warpImage(morphFrame,vx,vy);
    morpht = frame1*(frac)+morphedFrame*(1-frac);
end