# !/bash/bin

##
# Linux debian installation
##
if [ "$1" == "debian" ]; then
    sudo apt-get update
    sudo apt-get install clang cmake ninja-build pkg-config libgtk-3-dev libstdc++-12-dev
fi