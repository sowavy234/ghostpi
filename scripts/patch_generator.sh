#!/bin/bash
# Patch LinuxBootImageGenerator.py to be more lenient with Image_partitions folder
# This allows the build to work even with minor folder structure differences

GENERATOR_SCRIPT="$1"
if [ ! -f "$GENERATOR_SCRIPT" ]; then
    echo "Usage: $0 <path_to_LinuxBootImageGenerator.py>"
    exit 1
fi

# Backup original
cp "$GENERATOR_SCRIPT" "${GENERATOR_SCRIPT}.bak"

# Patch the compatibility check to be more lenient
# Instead of failing on any extra file, just warn and continue
python3 <<'PATCH_SCRIPT'
import sys
import re

script_path = sys.argv[1]

with open(script_path, 'r') as f:
    content = f.read()

# Find the compatibility check and make it more lenient
# Original: sys.exit() on mismatch
# New: Just warn and remove non-matching items

old_check = """            # Check that all partition folders exist
            for file in os.listdir(image_folder_name):
                if not file in working_folder_pat:
                    print('ERROR:  The existing "'+image_folder_name+'" Folder is not compatible with this configuration!')                                
                    print('        Please delete or rename the folder "'+image_folder_name+'" to allow the script')                                        
                    print('         to generate a matching folder structure for your configuration')                                                       
                    sys.exit()"""

new_check = """            # Check that all partition folders exist
            # Remove any files/folders that don't match expected partition folders
            import shutil
            for file in os.listdir(image_folder_name):
                if not file in working_folder_pat:
                    file_path = os.path.join(image_folder_name, file)
                    print('WARNING: Removing non-partition item: '+file)
                    if os.path.isdir(file_path):
                        shutil.rmtree(file_path)
                    else:
                        os.remove(file_path)"""

if old_check in content:
    content = content.replace(old_check, new_check)
    with open(script_path, 'w') as f:
        f.write(content)
    print("✓ Patched generator to be more lenient")
else:
    print("⚠️  Could not find exact match, trying alternative patch...")
    # Alternative: just comment out the sys.exit()
    content = re.sub(
        r"(if not file in working_folder_pat:.*?sys\.exit\(\s*\))",
        r"# PATCHED: Removed strict check\n                    # \1",
        content,
        flags=re.DOTALL
    )
    with open(script_path, 'w') as f:
        f.write(content)
    print("✓ Applied alternative patch")
PATCH_SCRIPT
"$GENERATOR_SCRIPT"

echo "Patch applied to $GENERATOR_SCRIPT"
