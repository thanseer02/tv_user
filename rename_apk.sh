#!/usr/bin/env bash

set -euo pipefail

# ============================================================
# Flutter APK Rename Script
# ============================================================
#
# Usage:
#
#   ./rename_apk.sh
#   ./rename_apk.sh uat
#   ./rename_apk.sh prod
#   ./rename_apk.sh uat --upload
#   ./rename_apk.sh --upload
#
# Drive setup: see docs/apk-drive-sharing.md.
#
# The script automatically reads:
#
#   App Name     -> android/app/src/main/AndroidManifest.xml
#   Server       -> lib/configs/app_configs.dart
#   Version      -> pubspec.yaml
#   Build Number -> pubspec.yaml
#   Date         -> Current date (IST)
#
# APK output example:
#
#   FairRide-Customer-DG-v1.0.0-build-1-2026-10-08-01.apk
#
# The final number is the copy/build sequence for that day:
#
#   ...-01.apk
#   ...-02.apk
#   ...-03.apk
#
# ============================================================


# ------------------------------------------------------------
# Move to Flutter project root
# ------------------------------------------------------------

project_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
cd -- "$project_dir"

upload=false
server_argument=""
for argument in "$@"; do
    case "$argument" in
        --upload) upload=true ;;
        *)
            if [[ -n "$server_argument" || ! "$argument" =~ ^[A-Za-z0-9_]+$ ]]; then
                echo "Usage: $0 [server] [--upload]" >&2
                exit 1
            fi
            server_argument="$argument"
            ;;
    esac
done

drive_destination="${APK_DRIVE_DESTINATION:-gdrive:APK Builds}"
if [[ "$upload" == true ]]; then
    if ! command -v rclone >/dev/null 2>&1; then
        echo "Drive upload requires rclone. See docs/apk-drive-sharing.md for setup." >&2
        exit 1
    fi
    if [[ ! "$drive_destination" =~ ^[A-Za-z0-9_-]+: ]]; then
        echo "APK_DRIVE_DESTINATION must be an rclone remote path, e.g. gdrive:APK Builds." >&2
        exit 1
    fi
fi


# ------------------------------------------------------------
# Project configuration
# ------------------------------------------------------------

config_file="lib/configs/app_configs.dart"

if [[ ! -f "$config_file" ]]; then
    echo "Error: Config file not found:"
    echo "$config_file"
    exit 1
fi

if [[ ! -f "pubspec.yaml" ]]; then
    echo "Error: pubspec.yaml not found."
    exit 1
fi


# ------------------------------------------------------------
# Read the app name from the Android application label.
# ------------------------------------------------------------

manifest_file="android/app/src/main/AndroidManifest.xml"
if [[ ! -f "$manifest_file" ]]; then
    echo "Error: Android manifest not found: $manifest_file" >&2
    exit 1
fi

app_name="$(
    sed -nE 's/.*android:label="([A-Za-z0-9 _-]+)".*/\1/p' "$manifest_file"
)"


# ------------------------------------------------------------
# ------------------------------------------------------------
# Read Server and isDebugMode from AppConfig
#
# Expected:
#
# static EnumBuildEnvironment server =
#     EnumBuildEnvironment.uat;
# static bool isDebugMode = true;
# ------------------------------------------------------------

config_server="$(
    sed -nE \
    's/^[[:space:]]*static EnumBuildEnvironment server[[:space:]]*=[[:space:]]*EnumBuildEnvironment\.([A-Za-z0-9_]+)[[:space:]]*;.*/\1/p' \
    "$config_file"
)"

is_debug_mode="$(
    sed -nE \
    's/^[[:space:]]*static[[:space:]]+bool[[:space:]]+isDebugMode[[:space:]]*=[[:space:]]*(true|false)[[:space:]]*;.*/\1/p' \
    "$config_file"
)"


# ------------------------------------------------------------
# Read version from pubspec.yaml
#
# Example:
#
# version: 1.0.7+25
#
# version      = 1.0.7
# build_number = 25
# ------------------------------------------------------------

full_version="$(
    awk '$1 == "version:" {
        gsub(/[\047\042]/, "", $2);
        print $2;
        exit
    }' pubspec.yaml
)"


# ------------------------------------------------------------
# Server
#
# Command argument has priority.
#
# ./rename_apk.sh prod
#
# Otherwise AppConfig.server is used.
# ------------------------------------------------------------

server="${server_argument:-$config_server}"


# ------------------------------------------------------------
# Validate configuration
# ------------------------------------------------------------

if [[ -z "$app_name" ]]; then
    echo "Error: Could not read a literal Android app label from:"
    echo "$manifest_file"
    exit 1
fi

if [[ -z "$server" || ! "$server" =~ ^[A-Za-z0-9_]+$ ]]; then
    echo "Error: Could not read a valid server."
    exit 1
fi

if [[ -z "$full_version" ||
      ! "$full_version" =~ ^[0-9]+\.[0-9]+\.[0-9]+(\+[0-9]+)?$ ]]; then

    echo "Error: Could not read a valid version from pubspec.yaml."
    exit 1
fi


# ------------------------------------------------------------
# Format App Name
#
# Example:
#
# miSales
#      ↓
# mi Sales
#      ↓
# mi-Sales
# ------------------------------------------------------------

app_display_name="$(
    printf '%s' "$app_name" |
    sed -E '
        s/([a-z0-9])([A-Z])/\1 \2/g;
        s/[_-]+/ /g
    '
)"

app_file_name="$(
    printf '%s' "$app_display_name" |
    sed -E 's/[[:space:]]+/-/g'
)"


# ------------------------------------------------------------
# Version + Build Number / Debug Build tag
# ------------------------------------------------------------

version="${full_version%%+*}"

build_number="Not specified"
build_suffix=""

if [[ "$full_version" == *+* ]]; then

    build_number="${full_version##*+}"

    build_suffix="-build-${build_number}"
fi

# When AppConfig.isDebugMode is true, replace the version and build tag with "debug-build"
if [[ "$is_debug_mode" == "true" ]]; then
    version_segment="debug-build"
else
    version_segment="v${version}${build_suffix}"
fi


# ------------------------------------------------------------
# Server formatting
# ------------------------------------------------------------

server_lower="$(
    printf '%s' "$server" |
    tr '[:upper:]' '[:lower:]'
)"

server_label="$(
    printf '%s' "$server" |
    tr '[:lower:]' '[:upper:]'
)"


# ------------------------------------------------------------
# Find APK
#
# First tries:
#
# app-uat-release.apk
#
# If not found:
#
# app-release.apk
# ------------------------------------------------------------

flavor_apk="build/app/outputs/flutter-apk/app-${server_lower}-release.apk"

normal_apk="build/app/outputs/flutter-apk/app-release.apk"


if [[ -f "$flavor_apk" ]]; then

    apk_path="$flavor_apk"

elif [[ -f "$normal_apk" ]]; then

    apk_path="$normal_apk"

else

    echo ""
    echo "Error: Release APK not found."
    echo ""
    echo "Checked:"
    echo "  $flavor_apk"
    echo "  $normal_apk"
    echo ""
    echo "Build the APK first."
    echo ""

    exit 1
fi


# ------------------------------------------------------------
# Output folder
# ------------------------------------------------------------

output_dir="build/apks"

mkdir -p "$output_dir"


# ------------------------------------------------------------
# Current Date - India timezone
# ------------------------------------------------------------

build_date="$(
    TZ=Asia/Kolkata date +'%Y-%m-%d'
)"


# ------------------------------------------------------------
# Daily Copy Number
#
# 01
# 02
# 03
# ...
#
# Automatically finds the next available number.
# ------------------------------------------------------------

copy_number=1

while :; do

    copy_label="$(
        printf '%02d' "$copy_number"
    )"

    new_name="${app_file_name}-${server_label}-${version_segment}-${build_date}-${copy_label}.apk"

    new_path="$output_dir/$new_name"

    if [[ ! -e "$new_path" && ! -L "$new_path" ]]; then
        break
    fi

    copy_number=$((copy_number + 1))

done


# ------------------------------------------------------------
# Copy APK
# ------------------------------------------------------------

cp -- "$apk_path" "$new_path"


# ------------------------------------------------------------
# Result
# ------------------------------------------------------------

printf '\n'
printf '============================================\n'
printf '             APK READY TO SHARE\n'
printf '============================================\n\n'

printf '%s version %s (%s) is ready to share.\n' "$app_display_name" "$version" "$server_label"
printf 'The APK was copied successfully.\n\n'

printf 'App name      : %s\n' "$app_display_name"
printf 'Version       : %s\n' "$version"
printf 'Build number  : %s\n' "$build_number"
printf 'Server        : %s\n' "$server_label"
printf 'Date (IST)    : %s\n' "$build_date"
printf 'Copy number   : %s\n' "$copy_label"

printf '\n'
printf 'APK filename:\n'
printf '%s\n' "$new_name"

printf '\n'
printf 'Saved to:\n'
printf '%s\n' "$new_path"

printf '\n'
printf '============================================\n'


if [[ "$upload" == true ]]; then
    remote_path="${drive_destination%/}/$new_name"
    printf '\nUploading APK to Google Drive...\n'
    if ! rclone copyto "$new_path" "$remote_path" --immutable; then
        printf 'Upload failed. Your local APK is still available at:\n%s\n' "$new_path" >&2
        exit 1
    fi
    if ! share_link="$(rclone link "$remote_path")" || [[ -z "$share_link" ]]; then
        printf 'APK uploaded to %s, but public link creation failed.\n' "$remote_path" >&2
        printf 'Check your Workspace sharing policy and rclone permissions. Local APK: %s\n' "$new_path" >&2
        exit 1
    fi
    printf '\nAnyone-with-the-link share URL:\n%s\n' "$share_link"
    printf '%s\n' "$share_link" > "${new_path%.apk}.share-link.txt"
    if command -v pbcopy >/dev/null 2>&1 && printf '%s' "$share_link" | pbcopy; then
        printf 'Share link copied to clipboard.\n'
    fi
fi
