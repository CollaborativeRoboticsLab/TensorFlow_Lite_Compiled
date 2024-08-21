#!/bin/bash

# Set up variables
REPO_URL="https://api.github.com/repos/tensorflow/tensorflow"
LATEST_TAG=$(curl -s "${REPO_URL}/releases/latest" | jq -r .tag_name)
CURRENT_TAG=$(git describe --tags $(git rev-list --tags --max-count=1))

# Log the tags for debugging
echo "Latest TensorFlow Tag: ${LATEST_TAG}"
echo "Current Repository Tag: ${CURRENT_TAG}"

# Compare the tags
if [ "${LATEST_TAG}" = "${CURRENT_TAG}" ]; then
    echo "No new release found."
    exit 0
else
    echo "New release found: ${LATEST_TAG}"
fi

# Fetch release data from TensorFlow repository
RELEASE_DATA=$(curl -s "${REPO_URL}/releases/tags/${LATEST_TAG}")
RELEASE_NAME=$(echo "${RELEASE_DATA}" | jq -r .name)
RELEASE_BODY=$(echo "${RELEASE_DATA}" | jq -r .body)

# Log release information
echo "Release Name: ${RELEASE_NAME}"
echo "Release Notes: ${RELEASE_BODY}"

# Create a new release in the current repository
gh release create "${LATEST_TAG}" \
  --title "${RELEASE_NAME}" \
  --notes "${RELEASE_BODY}"

# Check if the release creation was successful
if [ $? -eq 0 ]; then
    echo "Release ${LATEST_TAG} created successfully."
else
    echo "Failed to create release ${LATEST_TAG}."
    exit 1
fi
