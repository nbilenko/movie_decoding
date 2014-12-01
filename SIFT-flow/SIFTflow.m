function[vx,vy,energylist] = SIFTflow(im1,im2,resize,display)

    if resize
        im1=imresize(imfilter(im1,fspecial('gaussian',7,1.),'same','replicate'),0.5,'bicubic');
        im2=imresize(imfilter(im2,fspecial('gaussian',7,1.),'same','replicate'),0.5,'bicubic');
    end

    im1=im2double(im1);
    im2=im2double(im2);

    cellsize=3;
    gridspacing=1;

    addpath(fullfile(pwd,'mexDenseSIFT'));
    addpath(fullfile(pwd,'mexDiscreteFlow'));

    sift1 = mexDenseSIFT(im1,cellsize,gridspacing);
    sift2 = mexDenseSIFT(im2,cellsize,gridspacing);

    SIFTflowpara.alpha=2*255;
    SIFTflowpara.d=40*255;
    SIFTflowpara.gamma=0.005*255;
    SIFTflowpara.nlevels=4;
    SIFTflowpara.wsize=2;
    SIFTflowpara.topwsize=10;
    SIFTflowpara.nTopIterations = 60;
    SIFTflowpara.nIterations= 30;

    tic;[vx,vy,energylist]=SIFTflowc2f(sift1,sift2,SIFTflowpara);toc

    warpI2=warpImage(im2,vx,vy);
    if display
        figure;imshow(im1);figure;imshow(im2);figure;imshow(warpI2);
    end

    % display flow
    clear flow;
    flow(:,:,1)=vx;
    flow(:,:,2)=vy;
    if(display)
        figure;imshow(flowToColor(flow));
    end
end