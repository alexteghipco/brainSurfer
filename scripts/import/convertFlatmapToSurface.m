function convertFlatmapToSurface(inFile, templateFile, oName, fsPath)
% Converts a FreeSurfer flatmap to a surface file.
%
% This function converts a FreeSurfer flatmap patch (e.g., `lh.cortex.patch.flat`) 
% into a FreeSurfer surface file (e.g., `lh.flat`). It adjusts the flatmap's 
% vertex indices and coordinates to match the original surface that was flattened, 
% making it compatible with tools like MATLAB for further analysis.
%
% **Syntax**
% -------
%   convertFlatmapToSurface(inFile, templateFile, oName, fsPath)
%
% **Description**
% ---------
%   convertFlatmapToSurface(inFile, templateFile, oName, fsPath) processes the flatmap 
%   and its corresponding original surface to create a surface file with expanded vertices 
%   and faces. It uses FreeSurfer's `mris_convert` to convert the flatmap into an ASC file 
%   and reconstructs the surface geometry.
%
% **Inputs**
% ------
%   inFile       - (String) Path to the flatmap file.
%                  - Example: `/path/to/rh.cortex.patch.flat`.
%
%   templateFile - (String) Path to the original surface file that was flattened.
%                  - Example: `/path/to/rh.inflated`.
%
%   oName        - (String) Path to the output surface file.
%                  - Example: `/path/to/output/rh.flat`.
%
%   fsPath       - (String) Path to the FreeSurfer installation directory.
%                  - Example: `/path/to/freesurfer`.
%                  - Default: `/Applications/freesurfer/7.1.0`.
%
% **Features**
% ---------
%   1. **Flatmap Conversion**:
%      - Uses FreeSurfer's `mris_convert` to convert the flatmap into an ASC file for processing.
%
%   2. **Vertex and Face Reconstruction**:
%      - Parses vertex indices, coordinates, and face data from the ASC file.
%      - Adjusts vertex coordinates to fit the template surface.
%
%   3. **Surface File Writing**:
%      - Reconstructs a surface file (`.surf.gii` or `.surf`) with expanded vertex and face data.
%
% **Examples**
% -------
%   **Example 1: Convert a Flatmap to Surface File**
%   % Define file paths
%   inFile = '/path/to/lh.cortex.patch.flat';  % Input flatmap
%   templateFile = '/path/to/lh.inflated';     % Original surface
%   oName = '/path/to/lh.flat';               % Output surface file
%   fsPath = '/Applications/freesurfer/7.1.0'; % FreeSurfer path
%
%   % Convert flatmap to surface
%   convertFlatmapToSurface(inFile, templateFile, oName, fsPath);
%
% **Notes**
% -----
%   - **Dependencies**:
%     * Requires FreeSurfer's `mris_convert` tool.
%     * Requires external functions `read_surf` and `write_surf` for reading and writing surfaces.
%   - **FreeSurfer Setup**:
%     * Ensure the `FS_LICENSE` file is located in the FreeSurfer directory.
%     * The `fsPath` input should point to the correct FreeSurfer installation directory.
%   - **Output**:
%     * The output file will match the geometry of the template surface but retain the flatmap's data.
%   - **ASC File Cleanup**:
%     * The intermediate ASC file is not automatically deleted. You may manually remove it after processing.
%
% **Author**
% -------
%   Alex Teghipco // alex.teghipco@sc.edu // Last Updated: 2024-12-01
%
% **See Also**
% --------
%   mris_convert, read_surf, write_surf

% get freesurfer path
if isempty(fsPath)
    fsPath = '/Applications/freesurfer/7.1.0';
end
setenv('FS_LICENSE', [fsPath '/license.txt']);
fsPath = [fsPath '/bin'];

[opth,~,~] = fileparts(oName);
if isempty(opth)
    opth = pwd;
end

% convert input file to asc
id = strfind(inFile,'/');
ascFile = [opth '/' inFile(id(end)+1:end) '.asc'];
system([fsPath '/mris_convert -p ' inFile ' ' ascFile])

% Open the file
fid = fopen(ascFile,'r');

% Initialize a cell array
cellArray = {};

% Read the file line by line
line = fgetl(fid);
while ischar(line)
    cellArray{end+1} = line;
    line = fgetl(fid);
end

% Close the file
fclose(fid);

% Get some meta-data about size
meta = str2num(cellArray{2});
nvert = meta(1);
nface = meta(2);

% get vertices
vertids = cellArray(3:2:(nvert*2)+2);
vertids2 = str2double(extractBefore(vertids,' vno='));
vertids3 = str2double(extractAfter(vertids,' vno='));

% get coordinates
coords = cellArray(4:2:(nvert*2)+2);
numCellArray = cellfun(@(x) str2double(strsplit(x)), coords, 'UniformOutput', false);
coords2 = cell2mat(numCellArray');

% get faces
faceids = cellArray((nvert*2)+3:2:end);
faceids = str2double(faceids);
faces = cellArray((nvert*2)+4:2:end);
faces = cellfun(@(x) str2double(strsplit(x)), faces, 'UniformOutput', false);
faces = cell2mat(faces');
faces(:,4) = [];

% make vertices fit template file
[vertO, ~] = read_surf(templateFile);
clear vertex_coords2
vertex_coords2 = zeros(size(vertO));
vertex_coords2(vertids3+1,1) = coords2(:,1);
vertex_coords2(vertids3+1,2) = coords2(:,2);
vertex_coords2(vertids3+1,3) = coords2(:,3);

write_surf(oName, vertex_coords2, faces+1);