#!/bin/zsh
# Simulates stopping the service by scaling max instances to 0
gcloud run services update toptal-web --max-instances=0 --region=us-central1
gcloud run services update toptal-api --max-instances=0 --region=us-central1