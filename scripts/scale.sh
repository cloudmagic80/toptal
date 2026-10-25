#!/bin/zsh
# Usage: ./scale.sh <min> <max>
gcloud run services update toptal-web \
  --min-instances=$1 \
  --max-instances=$2 \
  --region=us-central1