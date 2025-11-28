from PIL import Image
import sys

try:
    img = Image.open(r"c:\Users\biael\OneDrive\Documentos\ebook-direitos-e-cidadania\assets\images\flag_spritesheet.png")
    width, height = img.size
    print(f"Width: {width}, Height: {height}")
    # Assuming square frames, frames = width / height
    frames = width / height
    print(f"Estimated Frames: {frames}")
except Exception as e:
    print(e)
