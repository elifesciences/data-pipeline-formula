#!/bin/bash
# headless gcloud tools installation
# creates a directory 'gcloud'

set -e

extracted_dir_name="google-cloud-sdk"
rm -rf "$extracted_dir_name" "venv"

downloaded_file="google-cloud-sdk-220.0.0-linux-x86_64.tar.gz"
if [ ! -e "$downloaded_file" ]; then
    wget -c "https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/$downloaded_file"
    tar -xvzf "$downloaded_file"
fi

if [ ! -e venv ]; then
    virtualenv venv --python=$(which python2)
fi

source venv/bin/activate

if [ ! -e ".installed.flag" ]; then
    "./$extracted_dir_name/install.sh" --usage-reporting=no --quiet
    touch .installed.flag
fi

PATH=$PATH:"$extracted_dir_name/bin"
