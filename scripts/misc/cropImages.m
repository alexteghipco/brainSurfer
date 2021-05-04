function cropImages(inFiles,plot,emptyComponent)
% cropImages(inFiles,plot,emptyComponent) 
%
% cropImages takes as input a bunch of images (tested only with PNGs so far
% but any kind should work) that have brains in them and crops out
% everything other than the largest object in the image (i.e., the brain).
% cropImages finds the largest object in the image by assuming that the
% largest 'connected' segment of pixels is white. brainSurfer produces PNG
% screenshots that satisfy this condition so this script will both remove
% the colorbar from brainSurfer's screenshots, and crop the image around
% the brain. Cropped images will be saved in the same directory as the
% input images, but appended by the string '_cropped'.
%
% If inFiles is empty, you will be prompted to select files to crop using
% uipickfiles. Files are assumed to have 3 color channels (i.e., rgb)
%
% If plot is empty or set to 'false' no figures will be generated.
% Otherwise, cropImages will produce figures showing which parts of the
% image are incrementally removed as the image is converted from RGB to
% greyscale, then to a binarized image. 
%
% emptyComponent should be left empty or set to 1 for default
% settings. This will force the script to assume that the largest connected
% component in the image is empty (i.e., white) space. In case the script
% fails but you know which connected component corresponds to the empty
% space , then you can provide it here (e.g., you resized the window in
% brainSurfer by a lot and now it's the second largest component, second to
% the brain itself). If you do so, set emptyComponent to some number n
% (other than 1) which will be assumed to be the nth largest connected
% component.
%
% Alex Teghipco // alex.teghipco@uci.edu

if isempty(emptyComponent)
    emptyComponent = 1;
end

if isempty(plot)
    plot = 'false';
end

if isempty(inFiles)
    inFiles = uipickfiles;
end

for i = 1:length(inFiles)
    %disp(['Working on image ' num2str(i) ' of ' num2str(length(inFiles))])
    [rgbImage,~] = imread(inFiles{i});
    [rSz, cSz, ~] = size(rgbImage);
    grayImage = rgb2gray(rgbImage);
    binImage = imbinarize(grayImage);
    CC = bwconncomp(binImage); % use CC to find 'empty space'
    numPixels = cellfun(@numel,CC.PixelIdxList);
    [val,idx] = sort(numPixels);
    if emptyComponent == 1
        emptyPix = vertcat(CC.PixelIdxList{idx(end)}); % the largest component is empty space...invert it.
    else
        emptyPix = vertcat(CC.PixelIdxList{idx(end-(emptyComponent-1))}); % the 'nth' largest component
    end
    
    % inverting 'empty space' by cross referencing all indices in image doesn't
    % seem to be working so we have to try something else
    %     allPix = find(binImage);
    %     filledPix = setdiff(allPix,emptyPix);
    
    tmpFig = binImage;
    tmpFig(:) = 1; % 0s will be black
    tmpFig(emptyPix) = 0;
    
    switch plot
        case 'true'
            if i == 1
                f1 = figure;
            else
                figure(f1)
            end
            imshow(abs(1 - tmpFig))
            title('black pixels will be analyzed further (this image will probably include a colorbar)')
    end
    
    CC = bwconncomp(tmpFig);
    tmpFig = binImage;
    tmpFig(:) = 0; %0 is black by default
    numPixels = cellfun(@numel,CC.PixelIdxList);
    [val,idx] = sort(numPixels);
    largestCC = vertcat(CC.PixelIdxList{idx(end)});
    tmpFig(largestCC) = 1;
    
    switch plot
        case 'true'
            if i == 1
                f2 = figure;
            else
                figure(f2)
            end
            imshow(abs(1-tmpFig))
            title('black pixels will be cropped (this image should not include a colorbar)')
    end
    
    % now crop image
    [largestCC_s(:,1),largestCC_s(:,2)] = ind2sub([rSz,cSz],largestCC);
    r = rgbImage(:,:,1);
    g = rgbImage(:,:,2);
    b = rgbImage(:,:,3);
    
    r(setdiff(1:rSz,unique(largestCC_s(:,1))),:) = [];
    g(setdiff(1:rSz,unique(largestCC_s(:,1))),:) = [];
    b(setdiff(1:rSz,unique(largestCC_s(:,1))),:) = [];
    r(:,setdiff(1:cSz,unique(largestCC_s(:,2)))) = [];
    g(:,setdiff(1:cSz,unique(largestCC_s(:,2)))) = [];
    b(:,setdiff(1:cSz,unique(largestCC_s(:,2)))) = [];
    
    tmpImage(:,:,1) = r;
    tmpImage(:,:,2) = g;
    tmpImage(:,:,3) = b;
    switch plot
        case 'true'
            if i == 1
                f3 = figure;
            else
                figure(f3)
            end
            imshow(tmpImage)
            title('Finalized (cropped) image')
    end
    [f,s,t] = fileparts(inFiles{i});
    imwrite(tmpImage,[f '/' s '_cropped' t])
    clear r g b largestCC_s largestCC tmpImage tmpFig emptyPix CC 
end
