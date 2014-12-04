function opts = defineSIFTPara(opts)

	% from SIFT-flow/demo.m
	opts.cellsize=3;
	opts.gridspacing=1;
	opts.SIFTflowpara.alpha=2*255;
	opts.SIFTflowpara.d=40*255;
	opts.SIFTflowpara.gamma=0.005*255;
	optsSIFTflowpara.nlevels=4;
	opts.SIFTflowpara.wsize=2;
	opts.SIFTflowpara.topwsize=10;
	opts.SIFTflowpara.nTopIterations = 60;
	opts.SIFTflowpara.nIterations= 30;
	% <end from demo.m>
end