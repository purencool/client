# !/bash/bin


##
# Run Linux
##
if [ "$1" == "linux" ]; then
   flutter build linux --release
   rm -rf ./compiled/bundle
   mv ./build/linux/x64/release/bundle ./compiled/bundle
  # mv ./compile/bundle/utiltiy_app ./compile/bundle/$2
fi

##
# Run MacOs
##
#if [ "$1" == "macos" ]; then
#fi

##
# Run IOS
##
#if [ "$1" == "ios" ]; then
#fi

##
# Run Android
##
#if [ "$1" == "android" ]; then
#fi