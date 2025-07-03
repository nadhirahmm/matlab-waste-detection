%% Setup
gTruthPath = 'gTruth_path';
outputLabelDir = 'labels\train\';
outputImageDir = 'images\train\';
classList = {'cardboard', 'glass', 'metal', 'paper', 'plastic', 'trash'};

%% Create output folders if needed
if ~exist(outputLabelDir, 'dir'); mkdir(outputLabelDir); end
if ~exist(outputImageDir, 'dir'); mkdir(outputImageDir); end

%% Load ground truth
load(gTruthPath, 'gTruth');
data = objectDetectorTrainingData(gTruth);

% Get label column names
labelCols = data.Properties.VariableNames(2:end);

%% Loop through data
for i = 1:height(data)
    imgPath = data.imageFilename{i};
    if ~isfile(imgPath)
        warning('Missing image: %s', imgPath);
        continue;
    end

    img = imread(imgPath);
    [H, W, ~] = size(img);
    [~, fileName, ~] = fileparts(imgPath);
    labelFilePath = fullfile(outputLabelDir, fileName + ".txt");
    fileID = fopen(labelFilePath, 'w');

    for c = 1:numel(labelCols)
        className = labelCols{c};
        classID = find(strcmp(classList, className)) - 1;
        bboxes = data.(className){i};  % Cell array: extract bboxes for this class

        for j = 1:size(bboxes, 1)
            bbox = bboxes(j, :);  % [x, y, w, h]
            x_center = (bbox(1) + bbox(3)/2) / W;
            y_center = (bbox(2) + bbox(4)/2) / H;
            w = bbox(3) / W;
            h = bbox(4) / H;

            fprintf(fileID, '%d %.6f %.6f %.6f %.6f\n', classID, x_center, y_center, w, h);
        end
    end

    fclose(fileID);
    copyfile(imgPath, fullfile(outputImageDir, fileName + ".jpg"));
end

disp('gTruth converted to YOLO format and images copied.');