#!/usr/bin/env bash

check_dep() {
    local output
    if output=$("$@" 2>&1); then
        #TODO check concrete versions
        output=$(echo "$output" | head -n 1)
        echo -e " \u2611 $output"
    else
        echo -e " \u2612 error checking dependecy:: $*"
        echo -e "$output"
        exit $?
    fi
}

check_deps() {
    echo "checking dependencies"
    check_dep 'bash' '--version'
    check_dep 'curl' '--version'
    check_dep 'jq' '--version'
    check_dep 'unzip' '-v'
    check_dep 'git' '--version'
    check_dep 'md5sum' '--version'
    check_dep 'bc' '--version'
}

install() {
    check_deps
    echo ""
    local repo_slug
    repo_slug=$(git remote get-url origin | sed -n 's/.*github.com\/\(.*\).git/\1/p')
    if [ -z "$repo_slug" ]; then
        repo_slug="yoosiba/mrh"
    fi
    
    local latest
    latest=$(curl -s "https://api.github.com/repos/$repo_slug/releases/latest")
    
    local download_url
    download_url=$(echo "$latest" | jq -r '.assets[] | select(.name | test("mrh.zip")) | .browser_download_url')
    
    if [ -z "$download_url" ]; then
        echo "Error: Could not find release of 'mrh.zip' asset in repository $repo_slug."
        exit 1
    fi
    
    echo "download_url $download_url"
    curl -sOJL "$download_url"
    
    if [ -d ./mrh ]; then
        rm -rf ./mrh
    fi
    
    if [ ! -f "mrh.zip" ]; then
        echo "Error: Failed to download mrh.zip."
        exit 1
    fi
    
    unzip -qq ./mrh.zip -d ./mrh
    rm ./mrh.zip
    echo "finished instalation"
}

install