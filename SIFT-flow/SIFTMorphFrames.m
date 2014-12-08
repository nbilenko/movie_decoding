function morpht = SIFTMorphFrames(frame1,frame2,fvx,fvy,frac,cellsize,gridspacing,SIFTflowpara)
    f1SIFT = mexDenseSIFT(frame1,cellsize,gridspacing);
    f2SIFT = mexDenseSIFT(frame2,cellsize,gridspacing);
    [vx,vy,~]=SIFTflowc2f(f1SIFT,f2SIFT,SIFTflowpara);
    wvx = vx+frac*fvx;
    wvy = vy+frac*fvy;
    morphedFrame = warpImage(frame2,wvx,wvy);
    morpht = frame1*(frac)+morphedFrame*(1-frac);
end