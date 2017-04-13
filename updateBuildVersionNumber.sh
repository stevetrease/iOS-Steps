/bin/sh

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