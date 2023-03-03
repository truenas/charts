#!/bin/bash

VERSION="v4.31.1"
BINARY="yq_linux_amd64"
YQ_PATH="/tmp/yq"
if [[ ! -f "$YQ_PATH" ]]; then
  wget "https://github.com/mikefarah/yq/releases/download/${VERSION}/${BINARY}" -O "$YQ_PATH" && \
  chmod +x "$YQ_PATH"
fi

function check_args(){
    local arg=$1
    if [[ -z "$arg" ]]; then
        echo "Error: $2 not specified"
        exit 1
    fi
}

function copy_app() {
    local train=$1
    local app=$2

    # Check arguments have values
    check_args "$train"
    check_args "$app"

    # Grab version from Chart.yaml
    version=$("$YQ_PATH" '.version' "library/$train/$app/Chart.yaml")
    check_args "$version"

    # Make sure directories exist
    mkdir -p "$train/$app/$version"

    # Copy files over
    rsync --archive --delete "library/$train/$app/" "$train/$app/$version"
    # Rename values.yaml to ix_values.yaml
    mv "$train/$app/$version/values.yaml" "$train/$app/$version/ix_values.yaml"

    # Remove CI directory from the versioned app
    rm -r "$train/$app/$version/ci"

    # Grab icon and categories from Chart.yaml
    icon=$("$YQ_PATH" '.icon' "library/$train/$app/Chart.yaml")
    check_args "$icon"
    categories=$("$YQ_PATH" '.keywords' "library/$train/$app/Chart.yaml")
    check_args "$categories"

    # Create item.yaml
    echo "" > "$train/$app/item.yaml"
    ICON="$icon" "$YQ_PATH" '.icon_url = env(ICON)' --inplace "$train/$app/item.yaml"
    CATEGORIES="$categories" "$YQ_PATH" '.categories = env(CATEGORIES)' --inplace "$train/$app/item.yaml"

}

# TODO: Call this function for each changed app
copy_app "$1" "$2"
