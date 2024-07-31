#!/bin/bash
set -e
set -o pipefail
set -x

# Variables
github_org="ajaydhungel23"
github_personal_access_token="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"

# URL for obtaining the GitHub Runner Registration Token
registration_url="https://api.github.com/orgs/${github_org}/actions/runners/registration-token"

# Obtain the registration token
registration_response=$(curl -L -X POST -H "Accept: application/vnd.github+json" -H "Authorization: Bearer ${github_personal_access_token}" -H "X-GitHub-Api-Version: 2022-11-28" "${registration_url}")
registration_token=$(echo "${registration_response}" | jq -r '.token')

# Check if the token was obtained successfully
if [ "$registration_token" = "null" ]; then
    echo "Failed to obtain GitHub Runner Registration Token. Response: ${registration_response}"
    exit 1
fi

# Output the registration token
echo "GitHub Runner Registration Token: ${registration_token}"
echo "registration_token=${registration_token}"

# URL for obtaining the GitHub Runner Removal Token
removal_token_url="https://api.github.com/orgs/${github_org}/actions/runners/remove-token"

# Obtain the removal token
removal_response=$(curl -L -X POST -H "Accept: application/vnd.github+json" -H "Authorization: Bearer ${github_personal_access_token}" -H "X-GitHub-Api-Version: 2022-11-28" "${removal_token_url}")
removal_token=$(echo "${removal_response}" | jq -r '.token')

# Check if the token was obtained successfully
if [ "$removal_token" = "null" ]; then
    echo "Failed to obtain GitHub Runner Removal Token. Response: ${removal_response}"
    exit 1
fi

# Output the removal token
echo "GitHub Runner Removal Token: ${removal_token}"
echo "removal_token=${removal_token}"

# Optionally, you can remove the runner using the removal token
# ./config.sh remove --token ${removal_token}
