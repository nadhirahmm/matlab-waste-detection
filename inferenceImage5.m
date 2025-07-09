%% Setup
modelfile = "C:\Users\nadhi\OneDrive\Desktop\ALLAHU AKBAR TA!!\YOLOv5\yolov5\runs\train\trashnet_yolov5s2\weights\best.onnx";
% python export.py --weights runs/train/trashnet_yolov5s2/weights/best.pt --imgsz 416 --include onnx --simplify 
labels = ["cardboard", "glass", "metal", "paper", "plastic", "trash"];
colorMap = lines(numel(labels));  % 6 distinct RGB col

%% Import ONNX network
net = importNetworkFromONNX(modelfile);

%% Read and preprocess image
orig = imread("C:\Users\nadhi\OneDrive\Documents\YOLO-TrashNet\images\val\cardboard261.jpg");
img = imresize(orig, [416 416]);
img = single(img) / 255;
img = reshape(img, [416, 416, 3, 1]);
img = dlarray(img, 'SSCB');

%% Run inference
predict(net, img);
tic;
output = predict(net, img);
output = permute(extractdata(output), [2 3 1]);
inferenceTime = toc;
fprintf("Inference time: %.0f ms\n", inferenceTime * 1000);

%% Postprocess
boxes = output(:,1:4); obj = output(:,5); classScores = output(:,6:end);
[score_cls, clsID] = max(classScores, [], 2);
scores = obj .* score_cls;

th = 0.3;
idx = scores > th;
boxes = boxes(idx,:); scores = scores(idx); clsID = clsID(idx);

if isempty(scores)
    disp("!! No detections !!");
    return;
end

% Get top class
[~, bestIdx] = max(scores);
boxes = boxes(bestIdx, :);
scores = scores(bestIdx);
clsID = clsID(bestIdx);

% Convert [xc yc w h] to [x y w h]
boxes(:,1:2) = boxes(:,1:2) - boxes(:,3:4)/2;
scaleBack = [size(orig,2)/416, size(orig,1)/416, size(orig,2)/416, size(orig,1)/416];
boxes = boxes .* scaleBack;

%% Visualization
x = boxes(1); y = boxes(2); w = boxes(3); h = boxes(4);
labelH = 35;
labelY = max(y - labelH, 1);  % Clamp top label position

disp("Unique class indices (raw):");
disp(unique(clsID));

classStr = labels(clsID);
scoreStr = scores(:) * 100; disp(scoreStr)
ann = sprintf("%s: %.1f%%", classStr, scoreStr);
color = colorMap(clsID, :) * 255;

out = insertShape(orig, "Rectangle", [x y w h], ...
"Color", color, "LineWidth", 4); % Draw bounding box
out = insertShape(out, "FilledRectangle", [x, labelY, w, labelH], ...
    "Color", color, "Opacity", 1); % Draw filled label background above box
out = insertText(out, [x - 3, labelY - 8], ann, ...
    "Font", "Times New Roman", "BoxOpacity", 0, "TextColor", "white", "FontSize", 31); % Draw white label text on top

disp("Box being drawn:");
disp([x y w h]);

imshow(out);