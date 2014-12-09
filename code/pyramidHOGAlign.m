function alignt = pyramidHOGAlign(theesImg, toTheesImg)

    function score = scoreAlignment(dis, dat)
        dis = extractHOGFeatures(dis);
        dat = extractHOGFeatures(dat);
        [~,sz] = size(dis);
        score = 1-(sum((dis-dat).^2)/sz);
    end

    function [bestX,bestY] = pyrAlign(thisImg, toThisImg, resizeFactor)
        reduceFactor = 2.0;
        smallestDim = 25;

        resizedThis = imresize(thisImg, resizeFactor);
        resizedTo = imresize(toThisImg, resizeFactor);
        % we don't want to deal with too few pixels... let's say... 25x25?
        [xsz,ysz] = size(resizedThis);
        if xsz < smallestDim || ysz < smallestDim
            bestX = 0;
            bestY = 0;
            return;
        end
        [smallerX, smallerY] = pyrAlign(thisImg, toThisImg, resizeFactor/reduceFactor);
        aroundX = smallerX*reduceFactor;
        aroundY = smallerY*reduceFactor;
        bestScore = 0.0;
        for x = aroundX-1:aroundX+1
            for y = aroundY-1:aroundY+1
                shifted = circshift(resizedThis,[x,y]);
                score = scoreAlignment(shifted, resizedTo);
                if score > bestScore
                    bestX = x;
                    bestY = y;
                    bestScore = score;
                end
            end
        end
    end

    fullSize = 1.0;
    [bestX,bestY] = pyrAlign(theesImg, toTheesImg, fullSize);
    alignt = circshift(theesImg,[bestX,bestY]);
end