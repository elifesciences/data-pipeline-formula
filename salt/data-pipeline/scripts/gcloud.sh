#!/bin/bash
# headless gcloud tools installation
# creates a directory 'gcloud'

set -e

extracted_dir_name="google-cloud-sdk"

downloaded_file="google-cloud-sdk-220.0.0-linux-x86_64.tar.gz"
if [ ! -e "$downloaded_file" ]; then
    wget -c "https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/$downloaded_file"
fi

if [ ! $extracted_dir_name ]; then
    tar -xvzf "$downloaded_file"
fi

if [ ! -e venv ]; then
    virtualenv venv --python=$(which python2)
fi

source venv/bin/activate

if [ ! -e ".installed.flag" ]; then
    # google's install.sh calls a python install.py which does who-knows-what
    "./$extracted_dir_name/install.sh" --usage-reporting=no --quiet    
fi

touch .installed.flag

PATH=$PATH:"$extracted_dir_name/bin"
