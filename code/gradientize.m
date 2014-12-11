function data = gradientize(data,opts)
    function gradImg = doGradient(img,invert)
        gradImg = zeros(size(img));
        for py=2:size(img,1)
            for px=2:size(img,2)
                xgrad = sum(img(py,px,1:3)-img(py,px-1,1:3))/3;
                ygrad = sum(img(py,px,1:3)-img(py-1,px,1:3))/3;
                if invert
                    gradImg(py,px,1:3) = 1-mean([xgrad,ygrad]);
                else
                    gradImg(py,px,1:3) = mean([xgrad,ygrad]);
                end
            end
        end
    end

    for timepoint=1:opts.nT
        for guess=1:opts.nG
            for frame=1:opts.nframes
                data.guesses(timepoint, guess, frame, :, :, :) = doGradient(data.guesses(timepoint, guess, frame, :, :, :),opts.invert);
            end
        end
    end
end