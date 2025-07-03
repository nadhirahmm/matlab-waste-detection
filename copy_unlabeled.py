import os
import shutil

# Path setup
all_images_dir = r'all\images'
train_dir = r'images\train'
val_dir = r'images\val'
output_unlabeled_dir = r'unlabeled\images'

# Create output folder
os.makedirs(output_unlabeled_dir, exist_ok=True)

# Get list of labeled filenames
labeled_files = set()

for folder in [train_dir, val_dir]:
    for file in os.listdir(folder):
        if file.lower().endswith(('.jpg', '.jpeg', '.png')):
            labeled_files.add(file)

# Process all images in 'all' folder
unlabeled_count = 0

for file in os.listdir(all_images_dir):
    if file.lower().endswith(('.jpg', '.jpeg', '.png')):
        if file not in labeled_files:
            src = os.path.join(all_images_dir, file)
            dst = os.path.join(output_unlabeled_dir, file)
            shutil.copyfile(src, dst)
            unlabeled_count += 1

print(f'Copied {unlabeled_count} unlabeled images to:')
print(output_unlabeled_dir)