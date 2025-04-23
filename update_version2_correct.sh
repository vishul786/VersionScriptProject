#!/bin/bash

# 1. Go into app directory
cd app
echo "Changed to app directory"

# 2. Get current versionCode and print it
CURRENT_VERSION_CODE=$(grep -o "versionCode\s*=\s*[0-9]*" build.gradle.kts | grep -o "[0-9]*")
echo "Current versionCode: $CURRENT_VERSION_CODE"

# 3. Increment versionCode by one and print it
NEW_VERSION_CODE=$((CURRENT_VERSION_CODE + 1))
echo "New versionCode: $NEW_VERSION_CODE"

# 4. Get current versionName and print it
CURRENT_VERSION_NAME=$(grep -o 'versionName\s*=\s*"[^"]*"' build.gradle.kts | grep -o '"[^"]*"' | sed 's/"//g')
echo "Current versionName: $CURRENT_VERSION_NAME"

# 5. Ask user for new versionName and set it then print it
read -p "Enter new versionName: " NEW_VERSION_NAME
echo "New versionName: $NEW_VERSION_NAME"

# Update the build.gradle.kts file with new versions
sed -i -e "s/versionCode\s*=\s*$CURRENT_VERSION_CODE/versionCode = $NEW_VERSION_CODE/" \
       -e "s/versionName\s*=\s*\"$CURRENT_VERSION_NAME\"/versionName = \"$NEW_VERSION_NAME\"/" build.gradle.kts

# 6. Stage changes to build.gradle
git add build.gradle.kts
echo "Staged changes to build.gradle.kts"

# 7. Go back one directory to project root
cd ..
echo "Changed back to project root"

# 8. Commit version update with message
git commit -m "Bumped up version from $CURRENT_VERSION_NAME to $NEW_VERSION_NAME"
echo "Committed version update"

# 9. Tag with versionName
git tag -a "v$NEW_VERSION_NAME" -m "Version $NEW_VERSION_NAME"
echo "Added tag v$NEW_VERSION_NAME"

# 10. Push changes
git push && git push --tags
echo "Pushed changes and tags"
