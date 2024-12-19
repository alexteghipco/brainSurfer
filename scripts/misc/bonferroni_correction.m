function corrected_p = bonferroni_correction(p_values)
% Applies the Bonferroni correction to a vector of p-values.
%
% This function adjusts a set of p-values to control the family-wise error rate 
% using the Bonferroni correction method. It is commonly used in multiple hypothesis 
% testing to reduce the risk of Type I errors.
%
% **Syntax**
% -------
%   corrected_p = bonferroni_correction(p_values)
%
% **Description**
% ---------
%   corrected_p = bonferroni_correction(p_values) applies the Bonferroni correction 
%   to the input vector of p-values, scaling each p-value by the number of tests. 
%   Any corrected p-value exceeding 1 is capped at 1.
%
% **Inputs**
% ------
%   p_values - (Vector) A numeric vector of p-values to be corrected.
%              - Must be a row or column vector.
%
% **Outputs**
% -------
%   corrected_p - (Vector) Bonferroni-corrected p-values.
%                 - The output has the same dimensions as the input.
%
% **Features**
% ---------
%   1. **Bonferroni Adjustment**:
%      - Corrects each p-value by multiplying it by the number of hypotheses (`m`).
%
%   2. **Capping at 1**:
%      - Ensures that no corrected p-value exceeds the maximum allowable value of 1.
%
%   3. **Shape Preservation**:
%      - Maintains the input vector's original shape (row or column) in the output.
%
% **Examples**
% -------
%   **Example 1: Correct a Set of P-Values**
%   % Define a vector of p-values
%   p_values = [0.01, 0.04, 0.03, 0.20];
%
%   % Apply Bonferroni correction
%   corrected_p = bonferroni_correction(p_values);
%   disp(corrected_p);
%   % Output: [0.04, 0.16, 0.12, 0.80]
%
%   **Example 2: Handle a Column Vector**
%   % Define a column vector of p-values
%   p_values = [0.01; 0.04; 0.03; 0.20];
%
%   % Apply Bonferroni correction
%   corrected_p = bonferroni_correction(p_values);
%   disp(corrected_p);
%   % Output: [0.04; 0.16; 0.12; 0.80]
%
% **Notes**
% -----
%   - **Applicability**:
%     * The Bonferroni correction is a conservative method and may reduce statistical 
%       power, especially when the number of hypotheses is large.
%   - **Input Validation**:
%     * The function checks if `p_values` is a numeric vector. An error is raised 
%       otherwise.
%   - **Mathematical Definition**:
%     * Corrected p-value for each test: \( p_i^{corrected} = \min(p_i \cdot m, 1) \),
%       where \( m \) is the number of hypotheses (length of `p_values`).
%
% **Author**
% -------
%   Alex Teghipco // alex.teghipco@uci.edu // Last Updated: 2024-12-01
%
% **See Also**
% --------
%   fdr_bh, holm_bonferroni


% Ensure p_values is a numeric vector
if ~isvector(p_values) || ~isnumeric(p_values)
    error('Input must be a numeric vector of p-values.');
end

% Number of hypotheses/tests
m = length(p_values);

% Apply Bonferroni correction
corrected_p = p_values * m;

% Ensure that no p-value exceeds 1
corrected_p(corrected_p > 1) = 1;

% Maintain the original shape (row or column)
corrected_p = reshape(corrected_p, size(p_values));
