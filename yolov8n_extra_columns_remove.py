import os

# Configuration
labels_dir = "path_to_labels"

# Loop through label files
for filename in os.listdir(labels_dir):
    if filename.endswith(".txt"):
        file_path = os.path.join(labels_dir, filename)
        with open(file_path, 'r') as f:
            lines = f.readlines()

        cleaned_lines = []
        for line in lines:
            parts = line.strip().split()
            if len(parts) >= 5:
                # Keep only the first 5 elements (class, x_center, y_center, width, height)
                cleaned_line = ' '.join(parts[:5])
                cleaned_lines.append(cleaned_line + '\n')

        # Overwrite with cleaned data
        with open(file_path, 'w') as f:
            f.writelines(cleaned_lines)

print("All label files cleaned. Extra columns removed where present.")