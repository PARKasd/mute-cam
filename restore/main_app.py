from exploit.restore import restore_file
from pathlib import Path
import plistlib
import traceback
import reboot

running = True
passed_check = False
# tweaks
shutter_sound_enabled = False


gestalt_path = Path.joinpath(Path.cwd(), "com.apple.MobileGestalt.plist")

def print_option(num: int, active: bool, message: str):
    txt = str(num) + ". "
    if active:
        txt = txt + "[Y] "
    txt = txt + message
    print(txt)

while running:

    
    if not passed_check and Path.exists(gestalt_path) and Path.is_file(gestalt_path):
        passed_check = True
    
    if passed_check:


            print()
            # set the tweaks and apply
            # first open the file in read mode
            with open(gestalt_path, 'rb') as in_fp:
                plist = plistlib.load(in_fp)

            plist["CacheExtra"]["h63QSdBCiT/z0WU6rdQv6Q"] = "KH"
            plist["CacheExtra"]["zHeENZu+wbg7PUprwNwBWg"] = "KH/A"

            # write back to the file
            with open(gestalt_path, 'wb') as out_fp:
                plistlib.dump(plist, out_fp)
            # restore to the device
            try:
                restore_file(fp=gestalt_path, restore_path="/var/containers/Shared/SystemGroup/systemgroup.com.apple.mobilegestaltcache/Library/Caches/", restore_name="com.apple.MobileGestalt.plist")
                input("Success! Rebooting your device to see the changes.")
                reboot.cli()
            except Exception as e:
                print(traceback.format_exc())
                input("Press Enter to continue...")
            running = False

    else:
        print("No MobileGestalt file found!")
        print(f"Please place the file in \'{Path.cwd()}\' with the name \'com.apple.MobileGestalt.plist\'")
        print("Remember to make a backup of the file!!\n")
        print("1. Retry")
        print("2. Enter path\n")
        choice = int(input("Enter number: "))
        if choice == 2:
            new_path = input("Enter new path to file: ")
            gestalt_path = Path(new_path)
