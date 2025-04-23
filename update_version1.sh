#!/bin/bash

# --- Configuration ---
APP_DIR="app"        # Adjust if your app module has a different name
BUILD_GRADLE="build.gradle.kts" # Assuming you are using Kotlin DSL
COMMIT_MESSAGE="Bumped up version"

# --- Helper Functions ---

function get_version_code() {
  grep "versionCode = " "$APP_DIR/$BUILD_GRADLE" | awk -F'= ' '{print $2}'
}

function get_version_name() {
  grep "versionName = " "$APP_DIR/$BUILD_GRADLE" | awk -F'= "' '{print $2}' | sed 's/"//g'
}

function set_version_code() {
  local new_version_code="$1"
  sed -i '' "s/versionCode = .*/versionCode = $new_version_code/" "$APP_DIR/$BUILD_GRADLE"
}

function set_version_name() {
  local new_version_name="$1"
  sed -i '' "s/versionName = \".*\"/versionName = \"$new_version_name\"/" "$APP_DIR/$BUILD_GRADLE"
}

# --- Main Script ---

echo "--- Starting Version Update Script ---"

# 1. Go into app directory
echo "1. Navigating to $APP_DIR directory..."
cd "$APP_DIR" || { echo "Error: Could not navigate to $APP_DIR"; exit 1; }

# 2. Get current versionCode and print it
current_version_code=$(get_version_code)
echo "2. Current versionCode: $current_version_code"

# 3. Increment versionCode by one and print it
new_version_code=$((current_version_code + 1))
set_version_code "$new_version_code"
echo "3. New versionCode: $new_version_code (updated in $BUILD_GRADLE)"

# 4. Get current versionName and print it
current_version_name=$(get_version_name)
echo "4. Current versionName: $current_version_name"

# 5. Ask user for new versionName and set it then print it
read -p "5. Enter new versionName (e.g., 1.2.3): " new_version_name
if [ -z "$new_version_name" ]; then
  echo "Error: Version name cannot be empty. Exiting."
  exit 1
fi
set_version_name "$new_version_name"
echo "   New versionName set to: $new_version_name (updated in $BUILD_GRADLE)"

# 6. Stage changes to build.gradle
echo "6. Staging changes to $BUILD_GRADLE..."
git add "$BUILD_GRADLE" || { echo "Error: Could not stage $BUILD_GRADLE"; exit 1; }

# 7. Go back one directory to project root
echo "7. Navigating back to project root..."
cd .. || { echo "Error: Could not navigate back to project root"; exit 1; }

# 8. Commit version update with message Bumped up version
echo "8. Committing changes with message: '$COMMIT_MESSAGE'"
git commit -m "$COMMIT_MESSAGE" || { echo "Error: Could not commit changes"; exit 1; }

# 9. Tag with versionName
echo "9. Tagging commit with versionName: '$new_version_name'"
git tag "$new_version_name" || { echo "Warning: Could not create tag '$new_version_name'. Tag might already exist or there are other Git issues."; }

# 10. Push changes
echo "10. Pushing changes to remote repository..."
git push origin HEAD && git push origin "$new_version_name" || { echo "Warning: Could not push changes to the remote repository. Please check your Git configuration and connection."; }

echo "--- Version Update Process Completed ---"
