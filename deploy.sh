#!/usr/bin/env bash

# Simple script to deploy hugo site to Google Cloud Platform - cloud storage

# Fixes python/gsutil bug - https://github.com/GoogleCloudPlatform/gsutil/issues/961
# Ensure brew install python@3.7
#export CLOUDSDK_PYTHON=/usr/local/opt/python@3.7/bin/python3
export CLOUDSDK_PYTHON=/usr/local/bin/python3

# ensure right project settings
gcloud config set project cjbarker-website-1292

# Clear and recreate site
rm -rf public/
hugo

if [ ! -d "public" ]; then
    >&2 echo "public directory does not exist - unable to deploy"
    exit 2
fi

# Enable public readable bucket
gsutil defacl ch -u AllUsers:R gs://cjbarker.com
if [ $? -ne 0 ]; then
    >&2 echo "Unable to set public readable bucket"
    exit 3
fi

# Copy/sync files
cd public/
# Bug on parallel processing those -o flag
# https://github.com/GoogleCloudPlatform/gsutil/issues/1100
gsutil -o "GSUtil:parallel_process_count=1" -h "Cache-Control:public,max-age=3600" -m rsync -r -d . gs://cjbarker.com
if [ $? -ne 0 ]; then
    >&2 echo "Unable to copy files from public to bucket"
    exit 4
fi

# Set index & 404 pages
gsutil web set -m index.html -e 404.html gs://cjbarker.com
if [ $? -ne 0 ]; then
    >&2 echo "Unable to set index & 404 web pages"
    exit 5
fi

exit 0
