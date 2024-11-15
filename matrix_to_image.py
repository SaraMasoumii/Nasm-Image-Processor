from PIL import Image
import numpy as np

def rgb_matrix_to_image(input_file, output_image_path):
    with open(input_file, 'r') as f:
        # Read the dimensions
        n, m = map(int, f.readline().strip().split())
        
        # Initialize an empty numpy array for the image
        rgb_array = np.zeros((n, m, 3), dtype=np.uint8)
        
        # Read the RGB values and populate the array
        for i in range(n):
            for j in range(m):
                r, g, b = map(int, f.readline().strip().split())
                rgb_array[i, j] = [r, g, b]
                
    # Convert the numpy array to an image
    img = Image.fromarray(rgb_array)
    
    # Save the image
    img.save(output_image_path)

input_file = '/Users/sarahmasoumi/Desktop/FinalProject/Phase2/RGBmatrix/image2.txt'  # Path to your input RGB matrix file
output_image_path = '/Users/sarahmasoumi/Desktop/FinalProject/Phase2/Output_images/output_image2.jpg'  # Path to your output image file
rgb_matrix_to_image(input_file, output_image_path)
