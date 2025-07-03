% === CONFIGURATION ===
labelDir = 'path_to_labels';
classList = {'cardboard', 'glass', 'metal', 'paper', 'plastic', 'trash'};

% === INIT ===
labelFiles = dir(fullfile(labelDir, '*.txt'));
mislabeledCount = 0;

for i = 1:length(labelFiles)
    file = labelFiles(i).name;
    filePath = fullfile(labelDir, file);
    
    % Extract class name from file name
    for c = 1:length(classList)
        if contains(lower(file), classList{c})
            expectedClassID = c - 1;
            break;
        end
    end
    
    % Read label file
    data = readlines(filePath);
    data(cellfun('isempty', data)) = [];  % Remove empty lines
    
    for j = 1:numel(data)
        tokens = strsplit(data{j});
        if isempty(tokens)
            continue;
        end
        classID = str2double(tokens{1});
        
        if classID ~= expectedClassID
            mislabeledCount = mislabeledCount + 1;
            fprintf('Mismatch in file: %s (expected %d, got %d)\n', file, expectedClassID, classID);
            break;  % Only count one mismatch per file
        end
    end
end

fprintf('\n Checked %d label files.\n', length(labelFiles));
fprintf('Mislabeled files found: %d\n', mislabeledCount);