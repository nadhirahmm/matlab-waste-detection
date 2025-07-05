from ultralytics import YOLO
import os
from pathlib import Path
from tqdm import tqdm

# Path setup
image_dir = r'unlabeled\images'
output_dir = r'predicted\autolabel_yolov8n'
model_path = r'runs\detect\trashnet_yolov8n\weights\best.pt'

os.makedirs(output_dir, exist_ok=True)

# Load model
model = YOLO(model_path)

# Predict
results = model.predict(
    source=image_dir,
    save=False,
    save_txt=True,
    save_conf=True, # adds the confidence score per box in the label (to delete, run extra_columns_remove.py)
    project=output_dir,
    name='',  # save directly in output_dir
    imgsz=416,
    conf=0.25,
    verbose=True
)

print(f"\n Prediction complete. YOLO-format labels saved in: {os.path.join(output_dir, 'labels')}")
