# MATLAB-Based Lightweight YOLO for Waste Object Detection

This repository contains the complete workflow for implementing and evaluating lightweight YOLO models for waste object detection using MATLAB. It includes dataset preparation, annotation scripts, model conversion, and inference pipeline for real-time testing with static images and webcam input.

## 📂 Project Structure

📁 all/                  → Augmented and labeled waste images  
📁 images/               → Waste images split into train and val  
📁 labels/               → Waste labels split into train and val  
📄 files.py              → Python codes  
📄 files.m               → MATLAB script  
📄 data.yaml             → Essential for training  
📄 README.md             → This file  

## 🔍 Key Features

- **Dataset Preparation**: Utilizes TrashNet dataset, augmented and balanced across six waste classes: cardboard, glass, metal, paper, plastic, and trash.
- **Semi-Automatic Labeling**: Combines manual labeling with YOLOv8n-based pseudo-labeling for fast annotation.
- **Model Training**: Lightweight YOLO models (v5s, v7-Tiny, v8n) trained in Python with standardized training settings.
- **Model Conversion**: Trained models exported to ONNX for seamless integration with MATLAB.
- **MATLAB Inference**: Real-time and image-based object detection tested and visualized using MATLAB, including frame-by-frame FPS monitoring.
- **Performance Evaluation**: Compares model precision, recall, mAP, inference time, and real-time accuracy.

## ▶️ How to Run

### 🔧 1. Train YOLO Models in Python

# For YOLOv5s
python train.py --img 416 --batch 16 --epochs 50 --data data.yaml --weights yolov5s.pt --name trashnet_yolov5s

# For YOLOv7-Tiny
python train.py --img 416 --batch 16 --epochs 50 --data data.yaml --weights yolov7-tiny.pt --name trashnet_yolov7tiny

# For YOLOv8n
yolo task=detect mode=train model=yolov8n.pt data=data.yaml epochs=50 imgsz=416 batch=16 name=trashnet_yolov8n

### 🔄 Export Trained Weights to ONNX

# YOLOv5s
python export.py --weights best.pt --imgsz 416 --include onnx --simplify

# For YOLOv7-Tiny
python export.py --weights best.pt --img-size 416 --grid --simplify --dynamic-batch

# YOLOv8n
yolo export model=best.pt format=onnx imgsz=416 simplify=True opset=17

### 📥 2. Run Inference in MATLAB

Run the MATLAB scripts.

### 📊 3. Analyze Results

- Bounding boxes with labels and confidence
- Inference time per frame
- Live FPS monitoring during webcam input
- Static image testing across all waste classes

## 📑 License

This repository is shared for academic and experimental replication purposes only. Please refer to the respective licenses of the YOLO models and other tools used.

## 🤝 Acknowledgments

- YOLOv5 and YOLOv8 by https://github.com/ultralytics
- YOLOv7 by https://github.com/WongKinYiu/yolov7
- TrashNet Dataset by https://github.com/garythung/trashnet
- MATLAB ONNX tools by https://www.mathworks.com
