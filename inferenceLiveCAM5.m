%% Setup
cam = webcam('c922 Pro Stream Webcam'); % Logi C270 HD WebCam c922 Pro Stream Webcam
cam.Resolution = '640x480';
inputSize = [416 416];

labels = ["cardboard", "glass", "metal", "paper", "plastic", "trash"];
colorMap = lines(numel(labels));  % 6 distinct RGB colors

modelfile = "C:\Users\nadhi\OneDrive\Desktop\ALLAHU AKBAR TA!!\YOLOv5\yolov5\runs\train\trashnet_yolov5s2\weights\best.onnx";
net = importNetworkFromONNX(modelfile);

fprintf("Press Ctrl+C to stop webcam inference\n");

while true
    %% Capture Frame
    orig = snapshot(cam);

    %% Preprocess
    img = imresize(orig, inputSize);
    img = single(img) / 255;
    img = reshape(img, [416 416 3 1]);
    img = dlarray(img, 'SSCB');

    %% Inference
    predict(net, img);
    tic;
    output = predict(net, img);
    inferenceTime = toc;
    output = permute(extractdata(output), [2 3 1]);  % [25200 x 11]

    %% Postprocess
    boxes = output(:,1:4); obj = output(:,5); classScores = output(:,6:end);
    [score_cls, clsID] = max(classScores, [], 2);
    scores = obj .* score_cls;

    th = 0.5;
    idx = scores > th;
    boxes = boxes(idx,:); scores = scores(idx); clsID = clsID(idx);

    % Get Top Class
    finalBoxes = [];
    finalScores = [];
    finalClsIDs = [];

    if ~isempty(scores)
        uniqueClasses = unique(clsID);
        for c = uniqueClasses'
            classIdx = find(clsID == c);
            if isempty(classIdx)
                continue;
            end
            [~, localBest] = max(scores(classIdx));
            bestIdx = classIdx(localBest);

            finalBoxes = [finalBoxes; boxes(bestIdx, :)];
            finalScores = [finalScores; scores(bestIdx)];
            finalClsIDs = [finalClsIDs; clsID(bestIdx)];
        end

        boxes = finalBoxes;
        scores = finalScores;
        clsID = finalClsIDs;

        % Convert and Scale to Original Size
        boxes(:,1:2) = boxes(:,1:2) - boxes(:,3:4)/2;
        scaleBack = [size(orig,2)/416, size(orig,1)/416, size(orig,2)/416, size(orig,1)/416];
        boxes = boxes .* scaleBack;

        %% Visualization
        out = orig;
        for i = 1:size(boxes,1)
            x = boxes(i,1); y = boxes(i,2); w = boxes(i,3); h = boxes(i,4);
            cls = clsID(i);  % 0-based
            conf = scores(i);
            label = compose("%s: %.1f%%", labels(cls), conf*100);
            boxColor = colorMap(cls, :) * 255;

            % Draw bounding box
            out = insertShape(out, "Rectangle", [x y w h], ...
                "Color", boxColor, "LineWidth", 4);

            % Draw filled label background above box
            labelH = 35;
            labelY = max(y - labelH, 1);
            out = insertShape(out, "FilledRectangle", [x, labelY, w, labelH], ...
                "Color", boxColor, "Opacity", 1);

            % Draw white label text on top
            out = insertText(out, [x - 3, labelY - 8], label, ...
                "Font", "Times New Roman", "BoxOpacity", 0, "TextColor", "white", "FontSize", 31);
        end

        % Show FPS and inference time
        fps = 1 / inferenceTime;
        timingText = sprintf("FPS: %.1f | Inference: %.0f ms", fps, inferenceTime * 1000);
        % Estimate text position (top-right with margin)
        textMargin = 10;
        textBoxWidth = 260;  % adjust if needed
        textBoxHeight = 25;

        xRight = size(out,2) - textBoxWidth - textMargin;
        yTop = textMargin;
        out = insertText(out, [xRight yTop], timingText, ...
            "Font", "Times New Roman", "BoxColor", "black", "TextColor", "white", "FontSize", 22);
    else
        out = insertText(orig, [10 10], "No detection", ...
            "Font", "Times New Roman", "BoxColor", "red", "TextColor", "white", "FontSize", 20);
    end

    %% Display Frame
    imshow(out);
    drawnow;
end