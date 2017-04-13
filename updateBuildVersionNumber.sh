/bin/sh

LAST_VERSION=`cat ./version`
NEW_VERSION=$(($LAST_VERSION + 1))

echo $NEW_VERSION > version
echo "version:" $NEW_VERSION

PLB=/usr/libexec/PlistBuddy

for DELIVERABLE in "iOS Steps" "iOS Steps Today" "iOS Steps Watch" "iOS Steps Watch Extension"
do
	PLIST="$DELIVERABLE/Info.plist"
	$PLB -c "Set :CFBundleVersion $NEW_VERSION" "$PLIST"
done
