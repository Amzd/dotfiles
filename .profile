# This prevents games with SDL to minimize when alt-tabbed,
# which stops them from being moved to the back of the window switcher.
# The issue persists on GLFW games like Minecraft.
export SDL_VIDEO_MINIMIZE_ON_FOCUS_LOSS=0

# Always start OBS capture
export OBS_VKCAPTURE=1
. "$HOME/.cargo/env"
