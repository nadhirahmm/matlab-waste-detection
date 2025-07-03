import os
import random
import shutil
from pathlib import Path

# Configuration
base_dir = r'folder_path'
input_images = Path(base_dir) / 'all/images'
input_labels = Path(base_dir) / 'all/labels'

# Output directories
output_dirs = {
    'train_images': Path(base_dir) / 'images/train',
    'val_images': Path(base_dir) / 'images/val',
    'train_labels': Path(base_dir) / 'labels/train',
    'val_labels': Path(base_dir) / 'labels/val',
}

# Clear & recreate output dirs
for folder in output_dirs.values():
    if folder.exists():
        shutil.rmtree(folder)
    folder.mkdir(parents=True)

# Gather only labeled images
image_files = list(input_images.glob('*.jpg'))
labeled_files = [f for f in image_files if (input_labels / (f.stem + '.txt')).exists()]
random.shuffle(labeled_files)

split_idx = int(0.8 * len(labeled_files))
train_files = labeled_files[:split_idx]
val_files = labeled_files[split_idx:]

def copy_pairs(image_list, image_dst, label_dst):
    for img in image_list:
        lbl = input_labels / (img.stem + '.txt')
        if lbl.exists():
            print(f'Copying {img.name} and {lbl.name}')
            shutil.copy2(img, image_dst / img.name)
            shutil.copy2(lbl, label_dst / lbl.name)
        else:
            print(f'Skipped (no label): {img.name}')

# Copy train/val sets
copy_pairs(train_files, output_dirs['train_images'], output_dirs['train_labels'])
copy_pairs(val_files, output_dirs['val_images'], output_dirs['val_labels'])

print('Split complete: files copied into train/val folders.')