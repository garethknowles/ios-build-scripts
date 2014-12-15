#!/bin/sh

# "Gareth's Supreme iOS Distribution Builder

if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ]  || [ -z "$4" ]  ;
then
   echo "=== Gareth's iOS Distribution Builder ==="
   echo "Build and Archiver for Distribution Builds. Usage:"
   echo "makeDistributionBuild projectPath workspaceName schemeName ipaName"
   echo "The default action is to create an index.html file and a manifest.plist file based on ipa provided"
   echo "projectPath: the relative path to the root of the project"
   echo "workspaceName: name of the workspace"
   echo "schemeName: name of scheme"
   echo "ipaName: the name ouf the ipaFile"
   exit
fi

PROJECT_PATH=$1
echo "PROJECT_PATH=$PROJECT_PATH"

WORKSPACE_NAME=$2
echo "WORKSPACE_NAME=$WORKSPACE_NAME"

SCHEME_NAME=$3
echo "SCHEME_NAME=$SCHEME_NAME"

IPA_NAME=$4
echo "IPA_NAME=$IPA_NAME"

# 1. Clean Old Data
xctool \
  -workspace $PROJECT_PATH/$WORKSPACE_NAME \
  -scheme $SCHEME_NAME \
  -sdk iphoneos8.1 \
  clean 

# 2. Install Pods
(cd $PROJECT_PATH && pod install)

#3. Build App for Devices
xctool \
  -workspace $PROJECT_PATH/$WORKSPACE_NAME \
  -scheme $SCHEME_NAME \
  -sdk iphoneos8.1 \
  build 

# 4. Produce Xcode Archive
rm -rf $PROJECT_PATH/build/$IPA_NAME.xcarchive
xctool \
  -workspace $PROJECT_PATH/$WORKSPACE_NAME \
  -scheme $SCHEME_NAME \
  -configuration Release \
  -sdk iphoneos8.1 \
  archive \
  -archivePath $PROJECT_PATH/build/$IPA_NAME.xcarchive

# 5. Produce App .ipa  
rm -f $PROJECT_PATH/build/$IPA_NAME.ipa
xcodebuild -archivePath $PROJECT_PATH/build/$IPA_NAME.xcarchive\
  -exportArchive \
  -exportSigningIdentity "iPhone Distribution: Smile Machine Limited" \
  -exportFormat ipa \
  -exportPath $PROJECT_PATH/build/$IPA_NAME.ipa
