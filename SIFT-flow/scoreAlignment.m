function score = scoreAlignment(thisImg, thatImg)
    [x,y] = size(thisImg);
    scaleScore = x * y;
    score = 1-(sum(sum((thisImg-thatImg).^2))/scaleScore);
end