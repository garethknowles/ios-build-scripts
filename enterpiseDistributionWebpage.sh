#!/bin/bash

# Gareth's Awesome iOS Enterprise Distribution Webpage Builder

if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ];
then
   echo "=== Gareth's iOS Enterprise Distribution Webpage Builder ==="
   echo "Distribution Builder. Usage:"
   echo "enterpriseDistributionWebpage ipaPath fullURL outputPath"
   echo "The default action is to create an index.html file and a manifest.plist file based on ipa provided"
   echo "ipaPath: the path to the input ipa file"
   echo "fullURL: the absolute URL where your deployment of the ipa file will happen"
   echo "outputPath: the path to output the files locally to"
   exit
fi

IPA_PATH=$1
echo $IPA_PATH

IPA_FILE=`basename $IPA_PATH`
echo $IPA_FILE

FULL_URL=$2
OUTPUT_PATH=$3

rm -Rf $OUTPUT_PATH
mkdir -p $OUTPUT_PATH
cp IPATemplate/index.html $OUTPUT_PATH/.
cp IPATemplate/manifest.plist $OUTPUT_PATH/.
cp $IPA_PATH $OUTPUT_PATH/$IPA_FILE

unzip -j $IPA_PATH Payload/*.app/Info.plist -d $OUTPUT_PATH/.

# grabbing bundle identifier
BUNDLE_IDENTIFIER=`/usr/libexec/PlistBuddy -c "Print CFBundleIdentifier" $OUTPUT_PATH/Info.plist`
# grabbing comercial version number from plist.
COMERCIAL_VERSION=`/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" $OUTPUT_PATH/Info.plist`
# grabbing build version from plist
BUILD_VERSION=`/usr/libexec/PlistBuddy -c "Print CFBundleVersion" $OUTPUT_PATH/Info.plist`
# grabbing bundle name
BUNDLE_NAME=`/usr/libexec/PlistBuddy -c "Print CFBundleName" $OUTPUT_PATH/Info.plist`
# grabbing ipa size
IPA_SIZE=`ls -nl $IPA_PATH | awk '{print $5}'`
# grabbing ipa md5
IPA_MD5=`md5 -q $IPA_PATH`

echo "Found Values:"
echo $BUNDLE_IDENTIFIER
echo $COMERCIAL_VERSION
echo $BUILD_VERSION
echo $BUNDLE_NAME
echo $IPA_SIZE
echo $IPA_MD5

`/usr/libexec/PlistBuddy -c "Set items:0:metadata:bundle-identifier $BUNDLE_IDENTIFIER" $OUTPUT_PATH/manifest.plist`
`/usr/libexec/PlistBuddy -c "Set items:0:metadata:bundle-version $COMERCIAL_VERSION ($BUILD_VERSION)" $OUTPUT_PATH/manifest.plist`
`/usr/libexec/PlistBuddy -c "Set items:0:metadata:title $BUNDLE_NAME" $OUTPUT_PATH/manifest.plist`
`/usr/libexec/PlistBuddy -c "Set items:0:assets:0:url $FULL_URL/$IPA_FILE" $OUTPUT_PATH/manifest.plist`
`/usr/libexec/PlistBuddy -c "Set items:0:assets:0:md5-size $IPA_SIZE" $OUTPUT_PATH/manifest.plist`
`/usr/libexec/PlistBuddy -c "Set items:0:assets:0:md5s:0 $IPA_MD5" $OUTPUT_PATH/manifest.plist`

rm $OUTPUT_PATH/Info.plist

TIMESTAMP=`date`
echo $TIMESTAMP
export REPLACE_FULL_URL=s!{FULL_URL}!$FULL_URL!g
export REPLACE_BUNDLE_NAME=s/{BUNDLE_NAME}/$BUNDLE_NAME/g
export REPLACE_TIMESTAMP=s!{TIMESTAMP}!$TIMESTAMP!g
sed -e $REPLACE_FULL_URL -e "$REPLACE_BUNDLE_NAME" -e "$REPLACE_TIMESTAMP" IPATemplate/index.html > $OUTPUT_PATH/index.html
