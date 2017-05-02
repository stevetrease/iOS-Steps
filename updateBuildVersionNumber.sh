/bin/sh

LAST_BUILD=0
LAST_BUILD=`cat ./build`
NEW_BUILD=$(($LAST_BUILD + 1))

echo $NEW_BUILD > build
echo "build:" $NEW_BUILD

PLB=/usr/libexec/PlistBuddy

for DELIVERABLE in "iOS Steps" "iOS Steps Today" "iOS Steps Watch" "iOS Steps Watch Extension"
do
	PLIST="$DELIVERABLE/Info.plist"
	$PLB -c "Set :CFBundleVersion $NEW_BUILD" "$PLIST"
done

sed -e "/userLabel=\"APP_VERSION\"/s/text=\"[^\"]*\"/text=\"Build: $NEW_BUILD\"/" "iOS Steps"/Base.lproj/LaunchScreen.storyboard
