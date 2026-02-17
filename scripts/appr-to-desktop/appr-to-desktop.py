#!/usr/bin/env python3
"""
Auto-create desktop entries for AppImages
"""

import os
import sys
import argparse
import shutil
import subprocess
from pathlib import Path

def create_desktop_entry(appimage_path, name=None, icon=None, install=False):
    """
    Create a desktop entry for an AppImage
    
    Args:
        appimage_path: Path to the AppImage file
        name: Custom name for the application (optional)
        icon: Custom icon name (optional)
        install: Install to system applications (default: create in ~/.local/share/applications)
    """
    appimage_path = Path(appimage_path).expanduser().resolve()
    
    if not appimage_path.exists():
        print(f"Error: AppImage not found at {appimage_path}")
        return False
    
    if not os.access(appimage_path, os.X_OK):
        print(f"Making AppImage executable: {appimage_path}")
        appimage_path.chmod(0o755)
    
    # Extract app name from filename
    if name is None:
        name = appimage_path.stem.replace('-', ' ').replace('_', ' ').title()
        name = ''.join(c for c in name if c.isalnum() or c in ' -_')
    
    # Default icon name
    if icon is None:
        icon = appimage_path.stem.lower().replace('-', '_').replace(' ', '_')
    
    # Create desktop entry content
    desktop_entry = f"""[Desktop Entry]
Comment=Application bundled as AppImage
Exec=appimage-run {appimage_path} %U
Icon={icon}
Name={name}
NoDisplay=false
Path=
PrefersNonDefaultGPU=false
StartupNotify=true
Terminal=false
TerminalOptions=
Type=Application
X-KDE-SubstituteUID=false
X-KDE-Username=
Categories=Utility;
MimeType=application/x-appimage;
"""
    
    # Determine where to save
    if install:
        # System-wide installation (requires sudo)
        if os.geteuid() != 0:
            print("Warning: System installation requires sudo. Falling back to user installation.")
            install = False
    
    if install:
        desktop_dir = Path('/usr/share/applications')
    else:
        desktop_dir = Path.home() / '.local' / 'share' / 'applications'
    
    desktop_dir.mkdir(parents=True, exist_ok=True)
    
    # Create filename from app name
    desktop_filename = name.lower().replace(' ', '-').replace('_', '-') + '.desktop'
    desktop_path = desktop_dir / desktop_filename
    
    # Check if desktop entry already exists
    if desktop_path.exists():
        print(f"Desktop entry already exists at {desktop_path}")
        choice = input("Overwrite? (y/N): ").lower()
        if choice != 'y':
            print("Aborted.")
            return False
    
    # Write desktop entry
    try:
        with open(desktop_path, 'w') as f:
            f.write(desktop_entry)
        
        desktop_path.chmod(0o644)
        print(f"Desktop entry created successfully!")
        print(f"  Location: {desktop_path}")
        print(f"  Name: {name}")
        print(f"  Executable: {appimage_path}")
        print(f"  Icon: {icon}")
        
        # Update desktop database
        update_desktop_database()
        
        return True
        
    except Exception as e:
        print(f"Error creating desktop entry: {e}")
        return False

def update_desktop_database():
    """Update the desktop database"""
    try:
        subprocess.run(['update-desktop-database', 
                       str(Path.home() / '.local' / 'share' / 'applications')], 
                      check=False)
        print("Desktop database updated.")
    except Exception as e:
        print(f"Note: Could not update desktop database: {e}")

def extract_appimage_info(appimage_path):
    """Try to extract information from AppImage using appimage-run"""
    try:
        # Try to get AppStream data
        result = subprocess.run(
            ['appimage-run', '--appimage-extract', '*.desktop', appimage_path],
            capture_output=True, text=True, check=False
        )
        if result.returncode == 0 and '.desktop' in result.stdout:
            print("Found embedded .desktop file in AppImage")
            # You could extract and parse this for better defaults
    except Exception:
        pass

def main():
    parser = argparse.ArgumentParser(
        description='Create desktop entries for AppImages',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  %(prog)s ~/Downloads/Godot_v4.6.AppImage
  %(prog)s --name "My App" --icon myapp-icon ~/Downloads/app.AppImage
  %(prog)s --install ~/Downloads/app.AppImage
        """
    )
    
    parser.add_argument('appimage', help='Path to the AppImage file')
    parser.add_argument('--name', '-n', help='Custom application name')
    parser.add_argument('--icon', '-i', help='Custom icon name')
    parser.add_argument('--install', action='store_true', 
                       help='Install system-wide (requires sudo)')
    parser.add_argument('--list-icons', action='store_true',
                       help='List available icon themes')
    
    args = parser.parse_args()
    
    if args.list_icons:
        # Simple icon listing
        icon_dirs = [
            '/usr/share/icons',
            '/usr/share/pixmaps',
            str(Path.home() / '.local/share/icons')
        ]
        for icon_dir in icon_dirs:
            if Path(icon_dir).exists():
                print(f"Icons in {icon_dir}:")
                for item in Path(icon_dir).rglob('*.png'):
                    print(f"  {item.stem}")
        return
    
    success = create_desktop_entry(
        args.appimage, 
        name=args.name, 
        icon=args.icon, 
        install=args.install
    )
    
    if success:
        print("\nThe application should now appear in your application menu.")
        print("You may need to log out and back in for changes to take effect.")
    else:
        sys.exit(1)

if __name__ == '__main__':
    main()
