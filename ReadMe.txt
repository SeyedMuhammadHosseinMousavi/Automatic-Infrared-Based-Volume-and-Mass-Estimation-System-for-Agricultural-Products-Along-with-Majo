# Automatic Infrared-Based Volume and Mass Estimation System for Agricultural Products

### Link to the paper:
- https://ieeexplore.ieee.org/document/9721526
- DOI: https://doi.org/10.1109/ICCKE54056.2021.9721526
### Link to the dataset:
- https://www.kaggle.com/datasets/hosseinmousavi/infraredbased-volume-and-mass-estimation-system

### Please cite:
Mousavi, Seyed Muhammad Hossein, and S. Muhammad Hassan Mosavi. "Automatic Infrared-Based Volume and Mass Estimation System for Agricultural Products: Along with Major Geometrical Properties." 2021 11th International Conference on Computer Engineering and Knowledge (ICCKE). IEEE, 2021.


## Overview
This repository provides the implementation and detailed methodology of the research paper titled:  
**"Automatic Infrared-Based Volume and Mass Estimation System for Agricultural Products Along with Major Geometrical Properties"**.

The paper proposes a robust system for estimating the **volume** and **mass** of agricultural products using RGB-D (Red-Green-Blue and Depth) images, specifically leveraging depth data captured via a Kinect v2 sensor. The system improves upon traditional and recent methods, offering **high accuracy**, **real-time performance**, and the ability to work under **pure darkness** conditions.

---

## Key Contributions
1. **Automatic Volume and Mass Estimation:**
   - A novel approach that uses depth data alongside color images for improved accuracy.
   - Capable of handling irregular and non-symmetrical shaped agricultural products.

2. **Geometrical Feature Extraction:**
   - Extracts ten features from 2D (color) and 3D (depth) data:
     - **2D Features:** Length, Width, Diameter, Perimeter.
     - **3D Features:** Thickness, Surface Area, Volume, Convex Volume, Solidity, and Mass.

3. **Real-Time Performance:**
   - The system achieves high computational efficiency, making it suitable for real-time applications.

4. **Darkness Compatibility:**
   - Utilizes Kinect's infrared sensor, allowing the system to operate in complete darkness.

---

## Table of Contents
- [Background](#background)
- [Proposed Methodology](#proposed-methodology)
  - [Preprocessing](#preprocessing)
  - [Feature Extraction](#feature-extraction)
- [Experimental Setup](#experimental-setup)
- [Results and Validation](#results-and-validation)
- [Future Work](#future-work)

---

## Background
Accurate grading of agricultural products is crucial for **quality management**, particularly for export. Traditional methods for volume (e.g., Water Displacement) and mass (e.g., Digital Balance) estimation are:
- **Time-consuming**
- **Prone to human error**
- **Inefficient for irregularly shaped products**

To address these challenges, the proposed system combines computer vision techniques and depth data to provide a **cost-effective**, **accurate**, and **automated solution**.

---

## Proposed Methodology

### Preprocessing
The system preprocesses both **color images** and **depth data**:
1. **Color Image Preprocessing:**
   - Convert RGB to Grayscale.
   - Apply median filtering to remove noise.
   - Use edge detection (Canny) and morphological operations to detect object boundaries.

2. **Depth Image Preprocessing:**
   - Use the raw depth map for extracting geometrical properties (e.g., thickness, volume).

### Feature Extraction
The system extracts **ten key features**:
1. **2D Features:**
   - **Length**: Maximum vertical extent.
   - **Width**: Maximum horizontal extent.
   - **Diameter**: Maximum diagonal extent.
   - **Perimeter**: Total boundary length of the object.

2. **3D Features:**
   - **Thickness**: Maximum depth variation.
   - **Surface Area**: Total area of the object's surface (calculated using triangular mesh geometry).
   - **Volume**: Derived from 3D triangular prisms formed by the depth data.
   - **Convex Volume**: Volume of the convex hull enclosing the object.
   - **Solidity**: Ratio of actual volume to convex volume.
   - **Mass**: Estimated using the formula:
     \[
     \text{Mass} = \text{Volume} \times \text{Density}
     \]
     where density is specific to the agricultural product.

---

## Experimental Setup
- **Dataset:**
  - 60 samples of agricultural products (Potatoes, Garlic, Carrots, Quinces).
  - Captured using Kinect v2 at a distance of 0.8 meters.
  - Lighting: Standard 6000k LED bulbs for uniform illumination.

- **Hardware:**
  - Kinect v2 for RGB-D data acquisition.
  - Processing done on a Windows machine with:
    - Intel Core i7 processor.
    - 32 GB RAM.
    - NVIDIA GTX 1050 GPU.

- **Software:**
  - MATLAB for feature extraction.
  - Python for implementation.

---

## Results and Validation
The proposed system was validated against traditional methods and recent research. Key metrics:
- **Mean Absolute Error (MAE):**
  - Volume: ~4% (Proposed) vs. 8-15% (Other methods).
  - Mass: ~2.5% (Proposed) vs. 5-10% (Other methods).
- **Mean Absolute Percentage Error (MAPE):**
  - Volume: ~1% (Proposed) vs. 3-6% (Other methods).
  - Mass: ~1% (Proposed) vs. 3-7% (Other methods).

---

## Future Work
- Extend the system to a larger variety of agricultural products.
- Use multiple cameras or angles for enhanced 3D feature extraction.
- Incorporate machine learning models for classification and prediction tasks.
