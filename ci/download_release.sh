#! /bin/bash

	REPO_SLUG="$1"
	ASSET_NAME="$2"
	ASSET_ID="$3"
	
	mkdir -p "$HOME/.local/appimages"
	asset_url="https://api.github.com/repos/$REPO_SLUG/releases/assets/$ASSET_ID"
	curl -XGET -o "$HOME/.local/appimages/$ASSET_NAME" --location --header "Accept: application/octet-stream" "${asset_url}"
