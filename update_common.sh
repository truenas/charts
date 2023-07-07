#!/bin/bash

VERSION="v4.31.1"
BINARY="yq_linux_amd64"
YQ_PATH="$(pwd)/yq"
BASE_PATH="library/ix-dev"

if [[ ! -d "$BASE_PATH" ]]; then
    echo "Error: [$BASE_PATH] does not exist"
    exit 1
fi

if [[ ! -f "$YQ_PATH" ]]; then
    echo "Downloading yq..."
    wget -q "https://github.com/mikefarah/yq/releases/download/${VERSION}/${BINARY}" -O "$YQ_PATH" && \
    chmod +x "$YQ_PATH"
    echo "Done"
fi

REPO="file://../../../common"
LATEST_COMMON_VERSION=$("$YQ_PATH" '.version' library/common/Chart.yaml)

trains=("charts" "community" "enterprise")

for train in "${trains[@]}"; do
    echo "🚂 Checking [$train]..."

    for app in "$BASE_PATH/$train"/*; do
        echo "===================================================================================================="
        echo "👀 Checking [$app]"

        if [[ ! -d "$app" ]]; then
            echo "🚫 Not a directory. Skipping..."
            continue
        fi

        if [[ ! -f "$app/Chart.yaml" ]]; then
            echo "🚫 No Chart.yaml found. Skipping..."
            continue
        fi

        deps=$("$YQ_PATH" '.dependencies[].name' "$app/Chart.yaml")
        for dep in $deps; do
            if [[ "$dep" != "common" ]]; then
                continue
            fi

            common_version=$("$YQ_PATH" '.dependencies[] | select(.name == "common") | .version' "$app/Chart.yaml")
            common_repo=$("$YQ_PATH" '.dependencies[] | select(.name == "common") | .repository' "$app/Chart.yaml")

            if [[ ! $(echo "$common_repo" | grep -e "^$REPO$") ]]; then
                echo "🚫 Common dependency is not from [$REPO] repo. Skipping..."
                continue
            fi

            echo "🔍 Found common dependency with version [$common_version] from repo [$common_repo]"
            if [[ -z "$common_version" ]]; then
                echo "🚫 Common dependency version is empty. Skipping..."
                continue
            fi

            if [[ "$common_version" == "$LATEST_COMMON_VERSION" ]]; then
                echo "✅ Common dependency is up to date"
                continue
            fi

            if [[ "$common_version" != "$LATEST_COMMON_VERSION" ]]; then
                echo "🔨 Updating common dependency to [$LATEST_COMMON_VERSION] from [$REPO]"
                "$YQ_PATH" --inplace '(.dependencies[] | select(.name == "common") | .version) = "'"$LATEST_COMMON_VERSION"'"' "$app/Chart.yaml"

                echo "🔨 Running helm dependency update for [$app]"
                helm dependency update "$app"
                curr_version=$("$YQ_PATH" '.version' "$app/Chart.yaml")

                # Split the version string into components
                IFS='.' read -r -a version_array <<< "$curr_version"

                # Extract the individual version components
                major="${version_array[0]}"
                minor="${version_array[1]}"
                patch="${version_array[2]}"

                # Increment the patch version
                patch=$((patch + 1))

                # Construct the updated version string
                next_version="$major.$minor.$patch"
                echo "🔨 Bumping Chart Version from [$curr_version] to [$next_version]"
                "$YQ_PATH" --inplace '(.version ) = "'"$next_version"'"' "$app/Chart.yaml"
                echo "✅ Done!"

            fi
        echo "===================================================================================================="
        echo ""
        done
    done
done
