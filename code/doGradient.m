function gradiented = doGradient(img, invert)
    [Gmag, ~] = imgradient(rgb2gray(img/255));
    gradiented = zeros(size(img));
    if ~invert
        Gmag = imcomplement(Gmag);
    end
    for i=1:3
        gradiented(:, :, i) = 255*Gmag;
    end
end