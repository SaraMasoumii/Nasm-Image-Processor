import cv2
import numpy as np

def read_grayscale_matrix(file_path):
    with open(file_path, 'r') as file:
        lines = file.readlines()

    # Read the number of rows and columns
    rows, cols = map(int, lines[0].strip().split())

    # Read the grayscale pixel values
    pixel_values = [int(line.strip()) for line in lines[1:]]

    # Convert the pixel values to a NumPy array and reshape it to the original dimensions
    gray_image = np.array(pixel_values, dtype=np.uint8).reshape((rows, cols))

    return gray_image

def save_image(image, output_path):
    cv2.imwrite(output_path, image)
    print(f"Image saved to {output_path}")


input_path = '/Users/sarahmasoumi/Desktop/FinalProject/Phase2/GrayScalematrix/image2.txt'             
output_image_path = '/Users/sarahmasoumi/Desktop/FinalProject/Phase2/GrayOutput_images/output_image2.jpg'  

grayscale_image = read_grayscale_matrix(input_path)

save_image(grayscale_image, output_image_path)
