/bin/sh

LAST_VERSION=`cat ./version`
NEW_VERSION=$(($LAST_VERSION + 1))

echo $NEW_VERSION > version
echo "version:" $NEW_VERSION

PLB=/usr/libexec/PlistBuddy

for DELIVERABLE in "iOS Steps" "iOS Steps Today" "iOS Steps Watch" "iOS Steps Watch Extension"
do
	echo $PLIST
	PLIST="$DELIVERABLE/Info.plist"
	$PLB -c "Set :CFBundleVersion $NEW_VERSION" "$PLIST"
done
echo
exit

PLIST="${PROJECT_DIR}/${INFOPLIST_FILE}"
PLB=/usr/libexec/PlistBuddy

LAST_VERSION=$($PLB -c "Print CFBundleVersion" "$PLIST")
NEW_VERSION=$(($LAST_VERSION + 1))

exit
$PLB -c "Set :CFBundleVersion $NEW_VERSION" "$PLIST")
