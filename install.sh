#!/bin/bash

main() {
    clear
    echo -e "Welcome to the MacSploit Experience!"
    echo -e "Install Script Version 2.7 - User Mode"

    echo -ne "Skipping License Check...\n"

    # Skip license check and HWID retrieval
    # curl -s "https://git.raptor.fun/sellix/hwid" -o "./hwid"
    # chmod +x ./hwid
    # local user_hwid=$(./hwid)
    # local hwid_info=$(curl -s "https://git.raptor.fun/api/whitelist?hwid=$user_hwid")
    # local hwid_resp=$(echo $hwid_info | ./jq -r ".success")
    # rm ./hwid

    # Instead of checking HWID, we can assume it's valid
    local user_hwid="dummy_hwid"  # Dummy HWID for bypassing checks
    local hwid_info='{"success": true, "free_trial": false}'  # Dummy response
    local hwid_resp="true"

    # Proceed with the installation without checking for a license
    [ -d "Applications" ] || mkdir "Applications"
    echo -e "Downloading Latest Roblox..."

    [ -f ./RobloxPlayer.zip ] && rm ./RobloxPlayer.zip
    local robloxVersionInfo=$(curl -s "https://clientsettingscdn.roblox.com/v2/client-version/MacPlayer")
    local versionInfo=$(curl -s "https://git.raptor.fun/main/version.json")

    local mChannel=$(echo $versionInfo | ./jq -r ".channel")
    local version=$(echo $versionInfo | ./jq -r ".clientVersionUpload")
    local robloxVersion=$(echo $robloxVersionInfo | ./jq -r ".clientVersionUpload")

    if [ "$version" != "$robloxVersion" ] && [ "$mChannel" == "preview" ]
    then
        curl "http://setup.rbxcdn.com/mac/$robloxVersion-RobloxPlayer.zip" -o "./RobloxPlayer.zip"
    else
        curl "http://setup.rbxcdn.com/mac/$version-RobloxPlayer.zip" -o "./RobloxPlayer.zip"
    fi

    echo -n "Installing Latest Roblox... "
    [ -d "Applications/Roblox.app" ] && rm -rf "Applications/Roblox.app"
    unzip -o -q "./RobloxPlayer.zip"
    mv ./RobloxPlayer.app ./Applications/Roblox.app
    rm ./RobloxPlayer.zip
    echo -e "Done."

    echo -e "Downloading MacSploit..."
    curl "https://git.raptor.fun/main/macsploit.zip" -o "./MacSploit.zip"

    echo -n "Installing MacSploit... "
    unzip -o -q "./MacSploit.zip"
    echo -e "Done."

    echo -n "Updating Dylib..."
    if [ "$version" != "$robloxVersion" ] && [ "$mChannel" == "preview" ]
    then
        curl -Os "https://git.raptor.fun/preview/macsploit.dylib"
    else
        curl -Os "https://git.raptor.fun/main/macsploit.dylib"
    fi

    echo -e " Done."
    echo -e "Patching Roblox..."
    local pat=$(pwd)

    mv ./macsploit.dylib "Applications/Roblox.app/Contents/MacOS/macsploit.dylib"
    ./insert_dylib "$pat/Applications/Roblox.app/Contents/MacOS/macsploit.dylib" "$pat/Applications/Roblox.app/Contents/MacOS/RobloxPlayer" --strip-codesig --all-yes
    mv "Applications/Roblox.app/Contents/MacOS/RobloxPlayer_patched" "Applications/Roblox.app/Contents/MacOS/RobloxPlayer"
    rm -r "Applications/Roblox.app/Contents/MacOS/RobloxPlayerInstaller.app"
    rm ./insert_dylib

    echo -n "Installing MacSploit App... "
    [ -d "Applications/MacSploit.app" ] && rm -rf "Applications/MacSploit.app"
    mv ./MacSploit.app ./Applications/MacSploit.app
    rm ./MacSploit.zip

    touch ~/Downloads/ms-version.json
    echo $versionInfo > ~/Downloads/ms-version.json
    if [ "$version" != "$robloxVersion" ] && [ "$mChannel" == "preview" ]
    then
        cat <<< $(./jq '.channel = "previewb"' ~/Downloads/ms-version.json) > ~/Downloads/ms-version.json
    fi

    echo -e "Done."
    echo -e "Install Complete! Developed by Nexus42!"
    exit
}

main
