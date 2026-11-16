import os
from PIL import Image

def generate_splash_assets():
    # Source circular logo with transparent corners
    src_logo_path = 'build/iconkitchen_extracted/web/icon-512.png'
    if not os.path.exists(src_logo_path):
        src_logo_path = 'build/iconkitchen_extracted/android/play_store_512.png'
        
    logo = Image.open(src_logo_path).convert('RGBA')
    
    # 1. Android 12+ Canvas (1152 x 1152, artwork centered in 768px safe circle)
    a12_canvas = Image.new('RGBA', (1152, 1152), (0, 0, 0, 0))
    a12_logo_size = 640 # fits safely inside the 768px circular mask
    logo_resized_a12 = logo.resize((a12_logo_size, a12_logo_size), Image.Resampling.LANCZOS)
    
    offset_a12 = ((1152 - a12_logo_size) // 2, (1152 - a12_logo_size) // 2)
    a12_canvas.paste(logo_resized_a12, offset_a12, logo_resized_a12)
    
    a12_path = 'assets/splash_logo_android12.png'
    a12_canvas.save(a12_path, 'PNG')
    print(f'Generated {a12_path} (1152x1152, centered logo @ {a12_logo_size}x{a12_logo_size})')
    
    # 2. Legacy / Standard Canvas (512 x 512, centered logo)
    std_canvas = Image.new('RGBA', (512, 512), (0, 0, 0, 0))
    std_logo_size = 400 # centered boldly and crisply
    logo_resized_std = logo.resize((std_logo_size, std_logo_size), Image.Resampling.LANCZOS)
    
    offset_std = ((512 - std_logo_size) // 2, (512 - std_logo_size) // 2)
    std_canvas.paste(logo_resized_std, offset_std, logo_resized_std)
    
    std_path = 'assets/splash_logo.png'
    std_canvas.save(std_path, 'PNG')
    print(f'Generated {std_path} (512x512, centered logo @ {std_logo_size}x{std_logo_size})')

if __name__ == '__main__':
    generate_splash_assets()
