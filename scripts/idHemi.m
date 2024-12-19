function hemi = idHemi(f, ln, rn, varargin)
% Identifies the Hemisphere Associated with a File Based on Its Name
%
%   hemi = idHemi(f, ln, rn)
%   hemi = idHemi(f, ln, rn, app)
%
% **Description**
% ------------
%   The `idHemi` function is designed to determine the hemisphere ('left', 'right', or [])
%   associated with a given set of brain data files based on specific naming conventions.
%   It analyzes file names to detect hemisphere indicators and handles cases where a file
%   may reference multiple hemispheres or lacks explicit hemisphere information.
%   Additionally, the function can interact with a graphical user interface (GUI) to prompt
%   the user for hemisphere selection when ambiguities arise.
%
% **Inputs**
% ----------
%   f       - (Cell array of strings) A cell array containing the full file paths to the
%             brain data files that need hemisphere identification.
%             *Example:*
%                 f = { 'path/to/subject1_left.nii', 'path/to/subject2.gii' };
%
%   ln      - (Cell array of strings) A cell array of substrings associated with the
%             left hemisphere. These strings are used to identify files related to the
%             left hemisphere based on their names.
%             *Example:*
%                 ln = { '_left', 'lh_', 'L_' };
%
%   rn      - (Cell array of strings) A cell array of substrings associated with the
%             right hemisphere. These strings are used to identify files related to the
%             right hemisphere based on their names.
%             *Example:*
%                 rn = { '_right', 'rh_', 'R_' };
%
%   app     - (Optional, App Designer Object) An optional app designer object. If provided,
%             the function utilizes `uiconfirm` dialogs within the app's figure for user
%             input when hemisphere ambiguity is detected. This enhances user experience
%             by integrating with the app's UI framework.
%             *Example:*
%                 app = MyAppDesignObject;
%
% **Outputs**
% ----------
%   hemi    - (Cell array of strings) A cell array where each element corresponds to the
%             hemisphere associated with the respective file in the input `f`. The possible
%             values are:
%                 - 'left'  : The file is associated with the left hemisphere.
%                 - 'right' : The file is associated with the right hemisphere.
%                 - []      : The hemisphere could not be determined or is unspecified.
%
% **Functionality**
% -----------------
%   The function performs the following steps for each file in the input list:
%     1. **File Name Preprocessing**:
%           - Converts the file name to lowercase to ensure case-insensitive matching.
%           - Removes occurrences of the substring 'lr' (which may indicate bilateral references)
%             to prevent false hemisphere identification.
%
%     2. **Hemisphere Detection**:
%           - Searches for the presence of any substrings in `ln` (left hemisphere indicators) within the
%             processed file name.
%           - Searches for the presence of any substrings in `rn` (right hemisphere indicators) within the
%             processed file name.
%
%     3. **Ambiguity Handling**:
%           - **Multiple Hemispheres Detected**:
%                 - If substrings for both hemispheres are found, the function prompts the user to specify
%                   which hemisphere the file should be associated with.
%                 - If an `app` object is provided, a `uiconfirm` dialog is displayed within the app's figure.
%                 - If no `app` object is provided, an `inputdlg` prompt is used.
%           - **No Hemisphere Indicators Detected**:
%                 - If no hemisphere-specific substrings are found, the function assumes the hemisphere is
%                   unspecified and prompts the user for assignment.
%                 - Similar to multiple hemisphere detections, the prompt method depends on whether an `app`
%                   object is provided.
%
%     4. **Default Hemisphere Assignment**:
%           - If only one hemisphere's indicators are detected, the function assigns the file to that hemisphere.
%           - If no indicators are detected and the user does not provide a hemisphere selection, the function
%             assigns an empty array (`[]`) to indicate an unspecified hemisphere.
%
% **Usage Examples**
% ------------------
%   % Example 1: Identifying Hemispheres Without GUI Interaction
%   f = { 'subject1_left.nii', 'subject2_right.gii', 'subject3.nii' };
%   ln = { '_left', 'lh_', 'L_' };
%   rn = { '_right', 'rh_', 'R_' };
%   hemi = idHemi(f, ln, rn);
%   % hemi = { 'left', 'right', [] }
%
%   % Example 2: Identifying Hemispheres with GUI Interaction via App Designer
%   app = MyAppDesignObject; % Assume MyAppDesignObject is a valid App Designer object
%   f = { 'subject1_left.nii', 'subject2.gii', 'subject3_lr.nii' };
%   ln = { '_left', 'lh_', 'L_' };
%   rn = { '_right', 'rh_', 'R_' };
%   hemi = idHemi(f, ln, rn, app);
%   % hemi might prompt the user for hemisphere selection for 'subject2.gii' and 'subject3_lr.nii'
%
% **Notes**
% --------
%   - **Supported File Formats**:
%       - The function does not inherently restrict to specific file formats but relies on naming
%         conventions to identify hemispheres. Common brain imaging file formats include:
%           - NIFTI (.nii)
%           - GIFTI (.gii)
%           - CIFTI (.dlabel.nii, etc.)
%           - Annotation and Label Files
%           - FreeSurfer Morphometry Files (.curv, etc.)
%
%   - **Hemisphere Indicators**:
%       - The substrings provided in `ln` and `rn` should uniquely identify the left and right hemispheres
%         in the file names. It's essential to ensure that these substrings do not overlap or cause
%         ambiguous matches.
%       - Example indicators:
%           - Left Hemisphere: '_left', 'lh_', 'L_'
%           - Right Hemisphere: '_right', 'rh_', 'R_'
%
%   - **Ambiguity Resolution**:
%       - When a file references both hemispheres or lacks explicit hemisphere indicators, the function
%         prompts the user to resolve the ambiguity.
%       - If an `app` object is provided, prompts are integrated within the app's GUI using `uiconfirm`.
%         This ensures a seamless user experience within the application's interface.
%       - If no `app` object is provided, standard MATLAB dialog prompts (`inputdlg`) are used.
%
%   - **Error Handling**:
%       - If the user cancels the hemisphere selection dialog, the function raises an error to indicate
%         that hemisphere assignment was not completed.
%
%   - **Customization**:
%       - Users can customize the substrings in `ln` and `rn` to match their specific file naming conventions.
%
%   - **Performance Considerations**:
%       - For large numbers of files, the function may prompt the user multiple times if ambiguities are frequent.
%         Consider pre-processing file names or ensuring consistent naming conventions to minimize prompts.
%
%   - **Function Limitations**:
%       - The function assumes that hemisphere indicators are present and correctly specified in the file names.
%         Incorrect or inconsistent naming conventions may lead to incorrect hemisphere assignments.
%
% **Author**
% -------
%   Alex Teghipco // alex.teghipco@uci.edu // Last Updated: 2024-12-01
%
% **See Also**
% ----------
%   load_nifti, gifti, cifti_read, read_annotation, read_label, read_curv, inputdlg, uiconfirm

    hemi = cell(length(f), 1);
    useApp = false;
    
    if nargin > 3
        brainSurferUIFigure = varargin{1};
        useApp = true;
    end
    
    for i = 1:length(f)
        f1 = f{i};
        id = strfind(lower(f1), 'lr'); % Some files will use the 'lr' string, which we need to remove to check for 'l' or 'r'.
        if ~isempty(id)
            % Ensure that 'lr' is within bounds before attempting to remove
            for j = length(id):-1:1
                if id(j) + 1 <= length(f1)
                    f1(id(j):id(j) + 1) = [];
                end
            end
        end
        f1 = {f1};
    
        % Define a function handle to search for substrings
        fun = @(s) ~cellfun('isempty', strfind(lower(f1), s));
        
        % Determine hemisphere indicators based on whether an app is provided
        if useApp
            out = cellfun(fun, ln, 'UniformOutput', false);
            out2 = cellfun(fun, rn, 'UniformOutput', false);
        else
            out = cellfun(fun, ln, 'UniformOutput', false);
            out2 = cellfun(fun, rn, 'UniformOutput', false);
        end
        
        % Sum the occurrences of hemisphere indicators
        os = sum(vertcat(out{:}));
        os2 = sum(vertcat(out2{:}));
    
        if os >= 1 && os2 >= 1
            % File references both hemispheres
            if useApp
                s = uiconfirm(brainSurferUIFigure, ...
                    ['It looks like a file you have loaded references more than one hemisphere. Which hemisphere do you associate with: ' f{i} '?'], ...
                    'Confirm Hemisphere', 'Options', {'Left', 'Right'}, 'DefaultOption', 1);
                hemi{i, 1} = lower(s);
            else
                s = inputdlg(['It looks like a file you have loaded references more than one hemisphere. Which hemisphere do you associate with: ' f{i} '?'], ...
                    'Confirm Hemisphere', 1, {'Left'});
                if isempty(s)
                    error('Hemisphere selection canceled.');
                end
                hemi{i, 1} = lower(s{1});
            end
        elseif os == 0 && os2 == 0
            % File does not clearly reference a hemisphere
            if useApp
                s = uiconfirm(brainSurferUIFigure, ...
                    ['It looks like a file you have loaded does not reference a hemisphere. Which hemisphere do you associate with: ' f{i} '?'], ...
                    'Confirm Hemisphere', 'Options', {'Left', 'Right'}, 'DefaultOption', 1);
                hemi{i, 1} = lower(s);
            else
                s = inputdlg(['It looks like a file you have loaded does not reference a hemisphere. Which hemisphere do you associate with: ' f{i} '?'], ...
                    'Confirm Hemisphere', 1, {'Left'});
                if isempty(s)
                    error('Hemisphere selection canceled.');
                end
                hemi{i, 1} = lower(s{1});
            end
        elseif os >= 1 && os2 == 0
            % File clearly references the left hemisphere
            hemi{i, 1} = 'left';
        elseif os == 0 && os2 >= 1
            % File clearly references the right hemisphere
            hemi{i, 1} = 'right';
        else
            % Hemisphere could not be determined
            hemi{i, 1} = [];
        end
    end
end
