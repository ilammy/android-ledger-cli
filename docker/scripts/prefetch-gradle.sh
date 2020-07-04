#!/bin/bash
#
# Prefetch Gradle stuff into a freshly built Docker image.
#
# Launch from repository root with a single argument: the tag name.
#
#     docker/scripts/prefetch-gradle.sh ilammy/android-ledger-cli:latest
#
# If not set then default tag name is used.
#
# The script will append a new later to the image with all the stuff
# Gradle downloads on the first run. This should eliminate or at least
# reduce the amount of stuff downloaded from the internets for building.

set -eu

DOCKER_IMAGE=${1:-ilammy/android-ledger-cli:latest}

DOCKER_PATH=/home/user/android-ledger-cli
DOCKER_CONTAINER=prefetch-gradle

# Populate the /home/user/.gradle directory. Keep the container (no --rm).
docker run -it --name=$DOCKER_CONTAINER -v $PWD:$DOCKER_PATH $DOCKER_IMAGE \
    /bin/sh -c "cd $DOCKER_PATH && ./gradlew --no-daemon dependencies"

# Now commit the current state of the container to the image.
docker commit --change 'CMD ["bash"]' $DOCKER_CONTAINER $DOCKER_IMAGE

# Drop the container we no longer need.
docker rm $DOCKER_CONTAINER
