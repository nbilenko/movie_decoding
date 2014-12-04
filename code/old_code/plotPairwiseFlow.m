function plotPairwiseFlow(n, g1, g2, ifs)
    % from demo.m
    cellsize=3;
    gridspacing=1;

    addpath(fullfile(pwd,'mexDenseSIFT'));
    addpath(fullfile(pwd,'mexDiscreteFlow'));

    SIFTflowpara.alpha=2*255;
    SIFTflowpara.d=40*255;
    SIFTflowpara.gamma=0.005*255;
    SIFTflowpara.nlevels=4;
    SIFTflowpara.wsize=2;
    SIFTflowpara.topwsize=10;
    SIFTflowpara.nTopIterations = 60;
    SIFTflowpara.nIterations= 30;
    % <end from demo.m>

    code1 = sprintf('data%03d',n);
    code2 = sprintf('data%03d',n+1);

    im1 = im2double(squeeze(ifs.lastframes.(code1)(g1,:,:,:,:)));
    im2 = im2double(squeeze(ifs.firstframes.(code2)(g2,:,:,:,:)));
    sift1 = mexDenseSIFT(im1,cellsize,gridspacing);
    sift2 = mexDenseSIFT(im2,cellsize,gridspacing);
    [vx,vy,energylist]=SIFTflowc2f(sift1,sift2,SIFTflowpara);
    warpI2=warpImage(im1,vx,vy);

    figure(1); imshow(im1);
    figure(2); imshow(im2);
    figure(3); imshow(warpI2);
    clear flow;
    flow(:,:,1)=vx;
    flow(:,:,2)=vy;
    figure(4);imshow(flowToColor(flow));
end

