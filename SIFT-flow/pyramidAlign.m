function [alignt,bestX,bestY] = pyramidAlign(thisImg, toThisImg, shiftRange)

    function [bestX,bestY] = pyrAlign(thisImg, toThisImg, resizeFactor)
        reduceFactor = 2.0;
        smallestDim = 200;

        resizedThis = imresize(thisImg, resizeFactor);
        resizedTo = imresize(toThisImg, resizeFactor);
        % we don't want to deal with too few pixels... let's say... 200x200?
        [x,y] = size(resizedThis);
        if x < smallestDim || y < smallestDim
            bestX = 0;
            bestY = 0;
            return;
        end
        [smallerX, smallerY] = pyrAlign(thisImg, toThisImg, resizeFactor/reduceFactor);
        aroundX = smallerX*reduceFactor;
        aroundY = smallerY*reduceFactor;
        bestScore = 0.0;
        for x = aroundX-(1/reduceFactor):aroundX+(1/reduceFactor)
            for y = aroundY-(1/reduceFactor):aroundY+(1/reduceFactor)
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

[bestX,bestY] = pyrAlign(thisImg, toThisImg, 1.0);
disp([bestX,bestY]);
alignt = circshift(thisImg,[bestX,bestY]);
end