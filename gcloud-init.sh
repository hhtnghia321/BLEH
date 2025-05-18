#!/bin/bash

# Print current project info
gcloud projects list
gcloud config list project

# # Set environment variables
# export LOCATION="us-central1"
# export PROJECT_ID=$(gcloud config get-value project)

# # Optional: Check if repo exists before creating
# gcloud artifacts repositories describe bleh-repo \
#   --location=$LOCATION 2>/dev/null || \
# gcloud artifacts repositories create bleh-repo \
#   --repository-format=docker \
#   --location=$LOCATION \
#   --description="Docker repo for BLEH application"

# # Authenticate Docker to use Artifact Registry
# gcloud auth configure-docker $LOCATION-docker.pkg.dev

# # Go to your app directory
# cd BLEH_application || exit 1

# # Build the image with a tag (add :0.1 to both build and push)
# export IMAGE_TAG="0.1"
# export IMAGE_PATH="$LOCATION-docker.pkg.dev/$PROJECT_ID/bleh-repo/bleh-app-img"
# export IMAGE_URI="$IMAGE_PATH:$IMAGE_TAG"

# # Build Docker image
# docker build -t $IMAGE_URI .

# # Push Docker image
# docker push $IMAGE_URI

# cd ..

# echo $IMAGE_URI


# Set required environment variables
export LOCATION="us-central1"
export PROJECT_ID=$(gcloud config get-value project)
export IMAGE_TAG="0.1"
export IMAGE_PATH="$LOCATION-docker.pkg.dev/$PROJECT_ID/bleh-repo/bleh-app-img"
export IMAGE_URI="$IMAGE_PATH:$IMAGE_TAG"

gcloud services enable cloudbuild.googleapis.com
gcloud services enable artifactregistry.googleapis.com

# Optional: Create repo if it doesn't exist
gcloud artifacts repositories describe bleh-repo \
  --location=$LOCATION 2>/dev/null || \
gcloud artifacts repositories create bleh-repo \
  --repository-format=docker \
  --location=$LOCATION \
  --description="Docker repo for BLEH application"

# Submit build to Cloud Build (ensure Dockerfile is in BLEH_application/)
gcloud builds submit ./BLEH_application \
  --tag "$IMAGE_URI" \
  --region="$LOCATION"

echo "✅ Image successfully built and pushed to: $IMAGE_URI"
