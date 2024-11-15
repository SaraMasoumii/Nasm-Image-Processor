import cv2
import numpy as np

def rgb_to_grayscale(image_path, output_path):
    # Load the image
    image = cv2.imread(image_path)

    # Check if image is loaded successfully
    if image is None:
        print("Error: Unable to load image.")
        return
    
    # Convert the image to grayscale
    gray_image = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)

    # Get the number of rows and columns
    rows, cols = gray_image.shape

    # Open the output file in write mode
    with open(output_path, 'w') as file:
        # Write the number of rows and columns
        file.write(f"{rows} {cols}\n")

        # Write the grayscale pixel values
        for row in gray_image:
            for pixel in row:
                file.write(f"{pixel}\n")

    print(f"Grayscale matrix written to {output_path}")

image_path = '/Users/sarahmasoumi/Desktop/FinalProject/Phase2/Input_images/image1.jpg'
output_path = '/Users/sarahmasoumi/Desktop/FinalProject/Phase2/GrayScalematrix/image1.txt'          
rgb_to_grayscale(image_path, output_path)
