/bin/sh

BUILD=`cat ./build`

echo "build:" $BUILD

PLB=/usr/libexec/PlistBuddy

for DELIVERABLE in "iOS Steps" "iOS Steps Today" "iOS Steps Watch" "iOS Steps Watch Extension"
do
	PLIST="$DELIVERABLE/Info.plist"
	$PLB -c "Set :CFBundleVersion $BUILD" "$PLIST"
done
