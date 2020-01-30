#! /bin/bash

	APP="$1"
	AINAME="$2"
	REPO_SLUG="$3"
	RELEASE_TAG="$4"
	
	rm -f assets.txt
	
	#echo "URL: https://api.github.com/repos/${REPO_SLUG}/releases/tags/${RELEASE_TAG}"
	RESPONSE=$(curl -XGET "https://api.github.com/repos/${REPO_SLUG}/releases/tags/${RELEASE_TAG}" 2> /dev/null)
	#echo "RESPONSE: $RESPONSE"
	RELEASE_ID=$(echo "$RESPONSE" |  grep '"id":' | head -n 1 | tr -s ' ' | cut -d':' -f 2 | tr -d ' ' | cut -d',' -f 1)
	#echo "RELEASE_ID: $RELEASE_ID"
	
	
	RELEASE_ASSETS=$(curl -XGET "https://api.github.com/repos/${REPO_SLUG}/releases/${RELEASE_ID}/assets" 2> /dev/null)
	ASSET_IDS=$(echo "$RELEASE_ASSETS" | grep '^    "id":')
	ASSET_NAMES=$(echo "$RELEASE_ASSETS" | grep '^    "name":')
	NASSETS=$(echo "$ASSET_IDS" | wc -l)
	NASSETS2=$(echo "$ASSET_NAMES" | wc -l)
	#echo "NASSETS:  $NASSETS"
	#echo "NASSETS2: $NASSETS2"
	
	if [ -z "$NASSETS" -o x"$NASSETS" != x"$NASSETS2" ]; then
		#echo "Could not retrieve list of assets"
		exit 1
	fi
	
	for AID in $(seq 1 $NASSETS); do
		ID=$(echo "$ASSET_IDS" | sed -n ${AID}p | tr -s " " | cut -f 3 -d" " | cut -f 1 -d ",")
		NAME=$(echo "$ASSET_NAMES" | sed -n ${AID}p | cut -d':' -f 2 | tr -d ' ' | cut -d'"' -f 2)
		TEST=$(echo "$NAME" | grep "$APP" | grep "AppImage$")
		TEST2=$(echo "$NAME" | grep "$APP" | grep "AppImage.sha256sum$")
		if [ -n "$TEST" ]; then
			ASSETS="${ASSETS}%${NAME}@${ID}"
		fi
		if [ -n "$TEST2" ]; then
			SHA256SUMS="${SHA256SUMS}%${NAME}.sha256sum@${ID}"
		fi
		#curl -XGET -o "$ASSET_NAME" --location --header "Accept: application/octet-stream" "${asset_url}"
		#curl -XGET "${asset_url}"
		#break
	done
	#echo "$ASSETS"
	
	LATEST=""
	if [ -n "$ASSETS" ]; then 
		LATEST="$(echo "$ASSETS" | tr '%' '\n' | sort | tail -n 1)"
	fi
	#echo "LATEST: $LATEST"
	
	#exit

	if [ x"$LATEST" != "x" ]; then
		ID=$(echo "$LATEST" | cut -d'@' -f 2)
		AI=$(echo "$LATEST" | cut -d'@' -f 1)
		ASSETS="$AI%${AINAME}"
		#echo "$AI" > assets.txt
		#echo "${APP}-${VERSION}" >> assets.txt
		NEWEST="$(echo "$ASSETS" | tr '%' '\n' | sort | tail -n 1)"
		#echo "CURRENT: ${APP}-${VERSION}"
		#echo "NEWEST: $NEWEST"
		if [ "$NEWEST" == "${AINAME}" ]; then
			#echo "Package is already at the latest version"
			exit
		fi
		if [ -n "$NEWEST" ]; then
			SHA256SUM="$(echo "$SHA256SUMS" | tr '%' '\n' | grep "$AI" | tail -n 1)"
			echo "${LATEST}%${SHA256SUM}"
			exit
		fi
		#./download_release.sh "$REPO_SLUG" "$AI" "$ID"
	fi