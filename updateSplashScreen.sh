/bin/sh

LAST_BUILD=0
LAST_BUILD=`cat ./build`
NEW_BUILD=$(($LAST_BUILD + 1))
GIT=`git rev-parse --short HEAD`

echo $NEW_BUILD > build
echo "build:" $NEW_BUILD $GIT

PLB=/usr/libexec/PlistBuddy

sed -i bak -e "/userLabel=\"APP_VERSION\"/s/text=\"[^\"]*\"/text=\"Build: $NEW_BUILD \($GIT\)\"/" "iOS Steps"/Base.lproj/LaunchScreen.storyboard
