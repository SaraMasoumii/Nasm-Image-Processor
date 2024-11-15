from PIL import Image
import numpy as np

def image_to_rgb_matrix(image_path, output_file):
    # Open the image file
    img = Image.open(image_path)
    # Ensure the image is in RGB mode
    img = img.convert('RGB')
    
    # Convert the image to a numpy array
    rgb_array = np.array(img)
    
    # Get the dimensions of the image
    n, m, _ = rgb_array.shape
    
    # Write the RGB matrix to the output file
    with open(output_file, 'w') as f:
        # Write the dimensions
        f.write(f"{n} {m}\n")
        # Write the RGB values
        for row in rgb_array:
            for pixel in row:
                f.write(f"{pixel[0]} {pixel[1]} {pixel[2]}\n")

image_path = '/Users/sarahmasoumi/Desktop/FinalProject/Phase2/Input_images/image1.jpg'  # Path to your input image
output_file = '/Users/sarahmasoumi/Desktop/FinalProject/Phase2/RGBmatrix/image1.txt'  # Path to your output file
image_to_rgb_matrix(image_path, output_file)
