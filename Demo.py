import cv2
import numpy as np
from scipy.spatial import ConvexHull
import matplotlib.pyplot as plt

# Preprocessing Function
def preprocess_image(image, is_depth=False):
    """Preprocess color or depth images."""
    if not is_depth:
        gray_image = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
    else:
        gray_image = image  # Depth images are already grayscale

    # Apply median filter for smoothing
    median_filtered = cv2.medianBlur(gray_image, 5)

    if not is_depth:
        # Apply Canny edge detection for color images
        edges = cv2.Canny(median_filtered, 100, 200)
        kernel = cv2.getStructuringElement(cv2.MORPH_ELLIPSE, (5, 5))
        return cv2.morphologyEx(edges, cv2.MORPH_CLOSE, kernel)
    else:
        # Return the depth image as is (after median filtering)
        return median_filtered

# Feature Extraction
def extract_features(color_image, depth_image):
    """Extract 2D and 3D features from color and depth data."""
    # Preprocess Images
    processed_color = preprocess_image(color_image)
    processed_depth = preprocess_image(depth_image, is_depth=True)

    # 2D Features (Length, Width, Diameter, Perimeter)
    contours, _ = cv2.findContours(processed_color, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
    max_contour = max(contours, key=cv2.contourArea) if contours else None

    if max_contour is None:
        print("No contours detected in the color image!")
        return None

    length = np.max(max_contour[:, :, 1]) - np.min(max_contour[:, :, 1])
    width = np.max(max_contour[:, :, 0]) - np.min(max_contour[:, :, 0])
    diameter = max(length, width)
    perimeter = cv2.arcLength(max_contour, True)

    # 3D Features (Thickness, Surface Area, Volume, Convex Volume, Solidity, Mass)
    thickness = np.max(processed_depth) - np.min(processed_depth)
    depth_points = np.column_stack(np.where(processed_depth > 0))

    if depth_points.shape[0] < 3:
        print("Not enough valid depth points to construct a Convex Hull. Setting default values.")
        convex_volume = 0
        surface_area = 0
    else:
        try:
            hull = ConvexHull(depth_points)
            convex_volume = hull.volume
            surface_area = hull.area
        except Exception as e:
            print("Convex Hull computation failed:", e)
            convex_volume = 0
            surface_area = 0

    volume = cv2.contourArea(max_contour) * thickness
    solidity = volume / convex_volume if convex_volume > 0 else 0
    mass = volume * 0.91  # Assuming specific density for the object

    return {
        "Length": length,
        "Width": width,
        "Diameter": diameter,
        "Perimeter": perimeter,
        "Thickness": thickness,
        "Surface Area": surface_area,
        "Volume": volume,
        "Convex Volume": convex_volume,
        "Solidity": solidity,
        "Mass": mass,
    }

# Load images
color_image_path = 'rgb1.jpg'
depth_image_path = 'depth1.png'

color_image = cv2.imread(color_image_path)
depth_image = cv2.imread(depth_image_path, cv2.IMREAD_GRAYSCALE)

# Ensure images are loaded
if color_image is None or depth_image is None:
    raise FileNotFoundError("Could not load one or both of the images. Check file paths.")

# Extract features
features = extract_features(color_image, depth_image)

if features:
    print("Extracted Features:")
    for feature, value in features.items():
        print(f"{feature}: {value}")

# Visualization
plt.figure(figsize=(12, 6))
plt.subplot(1, 2, 1)
plt.title("Color Image")
plt.imshow(cv2.cvtColor(color_image, cv2.COLOR_BGR2RGB))

plt.subplot(1, 2, 2)
plt.title("Processed Depth Image")
plt.imshow(preprocess_image(depth_image, is_depth=True), cmap='gray')

plt.show()
