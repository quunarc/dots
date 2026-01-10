# Disable windows in boot menu and prioritise Linux
disable_windows() {
    sudo efibootmgr -A -b 0000 > /dev/null
    sudo efibootmgr -A -b 0001 > /dev/null
    sudo efibootmgr -A -b 0002 > /dev/null
    sudo efibootmgr -A -b 0005 > /dev/null
    sudo efibootmgr -o 0003
    nrs > /dev/null &
}

# Offload task to the NVIDIA card
offload() {
  export __NV_PRIME_RENDER_OFFLOAD=1
  export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0
  export __GLX_VENDOR_LIBRARY_NAME=nvidia
  export __VK_LAYER_NV_optimus=NVIDIA_only
}

# Delete generations older than x days
delete_generations() {
    sudo nix profile wipe-history --profile /nix/var/nix/profiles/system --older-than $1d
}

# init_cpp_flake() {
#     if [[ $1 == "-dir" ]]; then
#         cp ~/Development/cpp-template/ -r .
#         mv ./cpp-template/ $2
#     else
#         cp ~/Development/cpp-template/flake.nix .
#     fi
# }

flac_to_mp3() {
    ffmpeg -i $1 -c:a libmp3lame -b:a 320k -map_metadata 0 -id3v2_version 3 output.mp3
}
