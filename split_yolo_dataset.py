import os
import random
import shutil
from pathlib import Path

# Set random seed for reproducibility
random.seed(42)

# Define paths
input_images_dir = Path("all/images")
input_labels_dir = Path("all/labels")

output_base_dir = Path("folder_path")
output_images_train = output_base_dir / "images/train"
output_images_val = output_base_dir / "images/val"
output_labels_train = output_base_dir / "labels/train"
output_labels_val = output_base_dir / "labels/val"

# Create output directories if they don't exist
for directory in [output_images_train, output_images_val, output_labels_train, output_labels_val]:
    os.makedirs(directory, exist_ok=True)

# Get list of all image files
image_files = list(input_images_dir.glob("*.jpg")) + list(input_images_dir.glob("*.png"))

# Shuffle the list
random.shuffle(image_files)

# Define split ratio
train_ratio = 0.8
train_count = int(len(image_files) * train_ratio)

# Split the dataset
train_files = image_files[:train_count]
val_files = image_files[train_count:]

def copy_files(file_list, images_dest, labels_dest):
    for image_path in file_list:
        label_path = input_labels_dir / (image_path.stem + ".txt")
        if label_path.exists():
            shutil.copy(image_path, images_dest / image_path.name)
            shutil.copy(label_path, labels_dest / label_path.name)
        else:
            print(f"Warning: Label file not found for image {image_path.name}")

# Copy training files
copy_files(train_files, output_images_train, output_labels_train)

# Copy validation files
copy_files(val_files, output_images_val, output_labels_val)

print(f"Dataset split completed. Training images: {len(train_files)}, Validation images: {len(val_files)}")