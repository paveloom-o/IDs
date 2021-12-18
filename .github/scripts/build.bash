#!/bin/bash

# A script to build the site on Ubuntu host

# Add local directory to the path
PATH=.:$PATH

# Install `curl`
apt-get update >/dev/null 2>&1 && apt-get install -y curl >/dev/null 2>&1

# Generate the content
./scripts/content.sh

# Get Zola
curl -L https://github.com/getzola/zola/releases/download/v0.15.2/zola-v0.15.2-x86_64-unknown-linux-gnu.tar.gz >zola.tar.gz 2>/dev/null
tar -xf zola.tar.gz && rm zola.tar.gz

# Build the site
if [ ${#} -eq 0 ]; then
    zola build
else
    zola build -u "${1}"
fi

# Delete Zola
rm zola

# Get `minify`
curl -L https://github.com/tdewolff/minify/releases/download/v2.9.22/minify_linux_amd64.tar.gz >minify.tar.gz 2>/dev/null
tar -xf minify.tar.gz minify && rm minify.tar.gz

# Use `minify`
minify -ra -o . public

# Delete `minify`
rm minify
