function cropImages(inFiles, fig)
% Removes the largest connected background region from images.
%
% This function processes a set of input images and crops them to remove
% the largest connected component of background pixels. It is designed
% to handle images with complex objects (e.g., brain maps) set against
% single-color backgrounds, automatically isolating the main object of
% interest.
%
% **Syntax**
% -------
%   cropImages(inFiles, fig)
%
% **Description**
% ---------
%   cropImages(inFiles, fig) processes the input images specified in `inFiles`
%   and saves cropped versions in the same directory as the input files.
%   The cropped images are appended with `_cropped` in their filenames.
%
%   If `inFiles` is empty, the user is prompted to select files interactively.
%
% **Inputs**
% ------
%   inFiles - (Cell Array or String) Paths to the input image files.
%             - Example: {'/path/to/image1.png', '/path/to/image2.png'}.
%             - If empty, the user is prompted to select files interactively.
%
%   fig     - (String or Logical) Flag to display processing steps.
%             - 'true' or `1`: Displays intermediate and final cropped images.
%             - 'false' or `0`: Suppresses image displays (default: 'false').
%
% **Features**
% ---------
%   1. **Background Removal**:
%      - Identifies the largest connected background region in an image
%        and removes it, preserving the main object of interest.
%
%   2. **Interactive File Selection**:
%      - If `inFiles` is empty, the function prompts the user to select
%        image files via a file dialog.
%
%   3. **Multi-Channel Support**:
%      - Processes images with three color channels (e.g., RGB).
%
%   4. **Cropped Image Saving**:
%      - Saves cropped images in the same directory as the input files,
%        appending `_cropped` to the filenames.
%
%   5. **Visualization**:
%      - Displays intermediate processing steps if `fig` is enabled.
%
% **Examples**
% -------
%   **Example 1: Crop Images Without Visualization**
%   % Process and crop a set of images without displaying steps
%   inFiles = {'/path/to/image1.png', '/path/to/image2.png'};
%   cropImages(inFiles, 'false');
%
%   **Example 2: Crop Images with Visualization**
%   % Process and crop images while displaying intermediate steps
%   inFiles = {'/path/to/image1.png', '/path/to/image2.png'};
%   cropImages(inFiles, 'true');
%
%   **Example 3: Interactive File Selection**
%   % Let the user select files to process interactively
%   cropImages([], 'true');
%
% **Notes**
% -----
%   - **Input Requirements**:
%     * Images must have three color channels (e.g., RGB).
%   - **File Types**:
%     * Tested with PNG images but should work with other image formats.
%   - **Output Files**:
%     * Cropped images are saved in the same directory as the input files,
%       with `_cropped` appended to the filenames.
%   - **Connected Components**:
%     * The function assumes the largest connected component is the background.
%       For atypical cases, consider modifying the script to specify the
%       background component manually.
%   - **Visualization**:
%     * Enabling `fig` displays intermediate steps, which is helpful for
%       debugging or visual verification of the cropping process.
%
% **Author**
% -------
%   Alex Teghipco // alex.teghipco@uci.edu // Last Updated: 2021
%
% **See Also**
% --------
%   imread, imwrite, imbinarize, regionprops

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
