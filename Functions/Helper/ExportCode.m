% A Custom publish script that includes the line
% number for each line in the function  
% Usage: Just run this script after specifying the 'filename'

% Specify the file you want to publish
filename = 'Functions\Quantity\Solar.m';

% Set publish options
function_options.format = 'html';
function_options.evalCode = false;
function_options.showCode = true;

% Temporary file to store the code with line numbers
temp_filename = 'mytemp.m';

% Open the original file for reading
fid1 = fopen(filename, 'r');
% Open the temporary file for writing
fid2 = fopen(temp_filename, 'w');

i = 1;  % Line counter

% Loop through each line of the original file
while true
    tline = fgetl(fid1);  % Read one line at a time
    if ~ischar(tline)  % Check for end of file
        break;
    end

    if ~isempty(tline)  % If line is not empty
        % Add line number as a comment to avoid syntax errors
        tline_with_number = [num2str(i), '\t', tline];  
        fprintf(fid2, '%s\n', tline_with_number);  % Write to temp file
        i = i + 1;  % Increment line number
    else
        fprintf(fid2, '\n');  % Keep empty lines
    end
end

% Close both files
fclose(fid1);
fclose(fid2);

% Publish the original file without line numbers
publish(filename, function_options);

% Publish the temp file with line numbers in comments
publish(temp_filename, function_options);

% Delete the temporary file after publishing
delete(temp_filename);

