% Configuration
inputRoot = 'raw_dataset_path'; 
outputRoot = 'save_path';

classNames = {'glass', 'paper', 'cardboard', 'plastic', 'metal', 'trash'};
maxPerClass = 594; % balance target (based on paper)

% Loop through each class
for i = 1:length(classNames)
    className = classNames{i};
    inputDir = fullfile(inputRoot, className);
    outputDir = fullfile(outputRoot, className);
    
    if ~exist(outputDir, 'dir'); mkdir(outputDir); end

    % Load original images
    imds = imageDatastore(inputDir, 'FileExtensions', {'.jpg','.png'}, 'IncludeSubfolders', false);
    numOrig = numel(imds.Files);

    fprintf('Class "%s": %d original images.\n', className, numOrig);

    % Copy originals to output
    for k = 1:numOrig
        [~, name, ext] = fileparts(imds.Files{k});
        copyfile(imds.Files{k}, fullfile(outputDir, [name, ext]));
    end

    % Determine the starting index for augmentation
    currentIndex = numOrig + 1;

    % Augmentation loop
    idx = 1;
    while numel(dir(fullfile(outputDir, '*.jpg'))) < maxPerClass
        img = readimage(imds, mod(idx-1, numOrig) + 1);
        
        % Random augmentations
        if rand < 0.5, img = imrotate(img, 90 * randi([1,3]), 'crop'); end % Rotation technique
        if rand < 0.5, img = fliplr(img); end % Horizontal Flipping technique
        if rand < 0.5
            hsv = rgb2hsv(im2double(img));
            hsv(:,:,3) = hsv(:,:,3) .* (0.6 + 0.4*rand); % Brightness Adjustment technique
            img = im2uint8(hsv2rgb(hsv));
        end
        if rand < 0.3
            noise = uint8(randn(size(img)) * 10);
            img = im2uint8(im2double(img) + double(noise)/255); % Gaussian Noise Addition technique
        end

        % Save with next sequential name
        outName = sprintf('%s%d.jpg', className, currentIndex);
        imwrite(img, fullfile(outputDir, outName));
        currentIndex = currentIndex + 1;
        idx = idx + 1;
    end

    fprintf('Augmented "%s" to %d images.\n', className, currentIndex - 1);
end

disp('All classes balanced, augmented, and named sequentially.');