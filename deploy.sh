#!/usr/bin/env bash

# Simple script to deploy hugo site to Google Cloud Platform - cloud storage

# Clear and recreate site
rm -rf public/
hugo

# todo check public exists

# Enable public readable bucket
gsutil defacl ch -u AllUsers:R gs://cjbarker.com
# todo add check to last error code and output

# Copy/sync files
cd public/
gsutil -m rsync -r -d . gs://cjbarker.com
# todo add check to last error code and output

# Set index & 404 pages
gsutil web set -m index.html -e 404.html gs://cjbarker.com
# todo add check to last error code and output

exit $?
