#!/bin/sh

# Remove container and associated volumes
docker stop znc-container
docker rm znc-container
docker volume rm znc-data

# Create volumes
docker volume create znc-data

# Start container
docker run -ti -p 1234:1234 --name znc-container -v znc-data:/znc-data znc
