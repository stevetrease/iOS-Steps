/bin/sh

LAST_NUMBER=`cat ./version`
NEW_NUMBER=$(($LAST_NUMBER + 1))

echo $NEW_NUMBER > version

PLB=/usr/libexec/PlistBuddy
for FILE in 

exit

PLIST="${PROJECT_DIR}/${INFOPLIST_FILE}"
PLB=/usr/libexec/PlistBuddy

LAST_NUMBER=$($PLB -c "Print CFBundleVersion" "$PLIST")
NEW_VERSION=$(($LAST_NUMBER + 1))

exit
$PLB -c "Set :CFBundleVersion $NEW_VERSION" "$PLIST")
