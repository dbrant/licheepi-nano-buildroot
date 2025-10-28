
export SDL_VIDEODRIVER=directfb
export SDL_FBDEV=/dev/fb0
export SDL_NOMOUSE=1
export SDL_AUDIODRIVER=dummy

cat /dev/zero > /dev/fb0
