function [alignt,bestX,bestY] = pyramidAlign(theesImg, toTheesImg)

    function score = scoreAlignment(dis, dat)
        [xsz,ysz,csz] = size(dis);
        score = 1-(sum(sum(sum((dis-dat).^2)))/(xsz*ysz*csz));
        if score < 0
            % we had color images we are SSDing; just divide by 255 in each
            % dimension to correct for this scaling
            score = 1-(sum(sum(sum((dis-dat).^2)))/(xsz*ysz*csz*255*255));
        end
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
    % we'll use one level of laplacian for it
    %gaussian = fspecial('gaussian',[15,15],5);
    %theesEdgeImg  = (theesImg-imfilter(theesImg,gaussian,'replicate'))/255;
    %toTheesEdgeImg  = (toTheesImg-imfilter(toTheesImg,gaussian,'replicate'))/255;
    %[bestX,bestY] = pyrAlign(theesEdgeImg, toTheesEdgeImg, fullSize);
    [bestX,bestY] = pyrAlign(theesImg, toTheesImg, fullSize);
    alignt = circshift(theesImg,[bestX,bestY]);
end