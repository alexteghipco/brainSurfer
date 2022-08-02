function cropImages2(inFiles,fig)
% cropImages(inFiles,plot,emptyComponent)
%
% cropImages takes as input a bunch of images (tested only with PNGs so far
% but any kind should work) and crops them so as to maximally remove the
% largest connected segment of pixels. If you have some complex object that
% contains lots of colors and it is set against a single colored
% background, this script will crop the image to remove as much of the
% background as possible. It works well with brain figures generated by
% brainSurfer (removing background and the colorbar) and is completely
% agnostic to the color of the background. Cropped images will be saved in
% the same directory as the input images, but appended by the string
% '_cropped'.
%
% If inFiles is empty, you will be prompted to select files to crop using
% uipickfiles (if you don't have uipickfiles either google it and add it to
% your matlab path or use a full file path in the input arguments). Files
% are assumed to have 3 color channels (i.e., rgb)
%
% If plot is empty or set to 'false' no figures will be generated.
% Otherwise, cropImages will produce figures showing which parts of the
% image are incrementally removed as the image is converted from RGB to
% greyscale, then to a binarized image.
%
% emptyComponent should be left empty or set to 1 for default settings.
% This will force the script to assume that the largest connected component
% in the image is empty space that needs to be removed. In case the script
% fails but you know which connected component corresponds to the empty
% space, then you can provide it here (e.g., you resized the window in
% brainSurfer by a lot and now it's the second largest component, second to
% the brain itself). If you do so, set emptyComponent to some number n
% (other than 1) which will be assumed to be the nth largest connected
% component.
%
% Alex Teghipco // alex.teghipco@uci.edu // 2021

if isempty(fig)
    fig = 'false';
end

if isempty(inFiles)
    [inFiles,pth] = uigetfile('*','MultiSelect','on');
    if ~iscell(inFiles)
        inFiles = {inFiles};
    end
    inFiles = strcat(pth,inFiles);
end

for i = 1:length(inFiles)
    [rgbImage,~] = imread(inFiles{i});
    [rSz, cSz, ~] = size(rgbImage);
    grayImage = rgb2gray(rgbImage);
    %binImage = imbinarize(grayImage,'adaptive','Sensitivity',0.55); % this threshold may not be perfect
    binImage = imbinarize(grayImage,0.99);
    binImage = imfill(abs(1-binImage),4,'holes');
    binImage = abs(1-binImage);

    if fig
        if i == 1
            f2 = figure;
        end
        figure(f2)
        imshow(binImage)
        title('Binarized image - you should see a white circle around the brain (ignore the colorbar)')
    end

    CC = bwconncomp(abs(1-binImage)); % invert image to find largest empty component and the index it maps onto...
    numPixels = cellfun(@numel,CC.PixelIdxList);
    [val,idx] = sort(numPixels);
    l = vertcat(CC.PixelIdxList{idx(end)});
    
    id = binImage ~= unique(binImage(l)); % background has to be zero...
    j = imclearborder(~id,4); % get border
    j = bwareafilt(j,1,'largest',4);

   % j = imfill(j,4,'holes');

%     id = j == 1-unique(binImage(l));
%     j = imclearborder(~id);
%     %j = bwareafilt(j,1);
%     [rSz, cSz, ~] = size(j);
%     [x(:,1),x(:,2)] = ind2sub([rSz,cSz],find(j == 1));
%     figure; imshow(rgbImage(min(x(:,1)):max(x(:,1)),min(x(:,2)):max(x(:,2)),:))
% 
    s = regionprops(j,'BoundingBox');
    ic = imcrop(binImage,s.BoundingBox);
    ic2 = imcrop(rgbImage,s.BoundingBox);

    if fig
        figure(f2)
        imshow(ic2)
        title('Initial crop - find border of 0s, fill everything inside, get bounding box (colorbar should be gone)')
    end

    % now refine...
%     id = ic == 1;
%     j = imclearborder(~id);
%     %j = bwareafilt(j,1);
%     [rSz, cSz, ~] = size(j);
%     [x(:,1),x(:,2)] = ind2sub([rSz,cSz],find(j == 1));
    [f,s,t] = fileparts(inFiles{i});
    %tmp = ic2(min(x(:,1)):max(x(:,1)),min(x(:,2)):max(x(:,2)),:);
    tmp = ic2;
    imwrite(tmp,[f '/' s '_cropped' t])
    if fig
        figure(f2)
        %imshow(ic2(min(x(:,1)):max(x(:,1)),min(x(:,2)):max(x(:,2)),:))
        title('Final, cropped image')
    end
    clear x 
end