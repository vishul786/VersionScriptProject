#!/bin/bash

#----- Configuration -----
APP_DIR="app"
BUILD_GRADLE="$APP_DIR/build.gradle.kts"
COMMIT_MESSAGE="Bumped up version"

#----- Functions -----

get_version_code() {
  grep "versionCode = " "$BUILD_GRADLE" | awk -F'= ' '{print $2}'
}

get_version_name() {
  grep "versionName = " "$BUILD_GRADLE" | awk -F'= "' '{print $2}' | sed 's/"//g'
}

set_version_code() {
  local new_version_code="$1"
  sed -i '' "s/versionCode = .*/versionCode = $new_version_code/" "$BUILD_GRADLE"
}

set_version_name() {
  local new_version_name="$1"
  sed -i '' "s/versionName = \".*\"/versionName = \"$new_version_name\"/" "$BUILD_GRADLE"
}

#----- Main Script -----

echo "--- Starting Version Update Script ---"

# 1. Get current versionCode and print it
current_version_code=$(get_version_code)
echo "1. Current versionCode: $current_version_code"

# 2. Increment versionCode by one and print it
new_version_code=$((current_version_code + 1))
set_version_code "$new_version_code"
echo "2. New versionCode: $new_version_code (updated in $BUILD_GRADLE)"

# 3. Get current versionName and print it
current_version_name=$(get_version_name)
echo "3. Current versionName: $current_version_name"

# 4. Ask user for new versionName and set it
read -p "4. Enter new versionName (e.g., 1.2.3): " new_version_name
if [ -z "$new_version_name" ]; then
  echo "Error: Version name cannot be empty. Exiting."
  exit 1
fi
set_version_name "$new_version_name"
echo "   New versionName set to: $new_version_name (updated in $BUILD_GRADLE)"

# 5. Stage changes
echo "5. Staging changes..."
git add "$BUILD_GRADLE" || { echo "Error: Could not stage file"; exit 1; }

# 6. Commit changes
echo "6. Committing changes with message: '$COMMIT_MESSAGE'"
git commit -m "$COMMIT_MESSAGE" || { echo "Error: Commit failed"; exit 1; }

# 7. Tag with versionName
echo "7. Tagging commit with: '$new_version_name'"
git tag "$new_version_name" || echo "Warning: Tag might already exist."

# 8. Push changes and tag
echo "8. Pushing changes and tag..."
git push origin HEAD && git push origin "$new_version_name" || echo "Warning: Push failed. Please check your git setup."

echo "--- ✅ Version Update Process Completed ---"
