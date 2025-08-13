#!/bin/bash
TOKEN=xxxxxxxxxxxxx
GROUP="docker"
REGEX='^rc-?[1-9]?-[0-9]+$'
GITLAB_URL="https://gitlab.example.com"
REGISTRY_URL="https://registry.example.com"

# 1. Get Group ID
GROUP_ID=$(curl --silent --header "PRIVATE-TOKEN: $TOKEN" "$GITLAB_URL/api/v4/groups?search=$GROUP" | jq '.[0].id')

# 2. Get all projects in the group
PROJECTS=$(curl --silent --header "PRIVATE-TOKEN: $TOKEN" "$GITLAB_URL/api/v4/groups/$GROUP_ID/projects?per_page=100" | jq -r '.[].id')

for PROJECT_ID in $PROJECTS; do
  PROJECT_NAME=$(curl --silent --header "PRIVATE-TOKEN: $TOKEN" "$GITLAB_URL/api/v4/projects/$PROJECT_ID" | jq -r '.path')
  echo "Processing Project Name: $PROJECT_NAME"

  PULL=$(curl -su "farid:$TOKEN" "$GITLAB_URL/jwt/auth?service=container_registry&scope=repository:$GROUP/$PROJECT_NAME:pull" | jq -r .token)
  DEL=$(curl -su "farid:$TOKEN" "$GITLAB_URL/jwt/auth?service=container_registry&scope=repository:$GROUP/$PROJECT_NAME:delete" | jq -r .token)

  # 3. Get all container registry repositories in the project
  REPOS=$(curl --silent --header "PRIVATE-TOKEN: $TOKEN" "$GITLAB_URL/api/v4/projects/$PROJECT_ID/registry/repositories" | jq -r '.[].id')

  for REPO_ID in $REPOS; do
    # 4. List all tags in the repository
    page=1
    tags=()
    while :; do
    	response=$(curl --silent --header "PRIVATE-TOKEN: $TOKEN" "$GITLAB_URL/api/v4/projects/$PROJECT_ID/registry/repositories/$REPO_ID/tags?per_page=100&page=$page")

 	# Break if empty response (no more tags)
  	[[ $(echo "$response" | jq length) -eq 0 ]] && break

  	# Append tags to array
  	tags+=($(echo "$response" | jq -r '.[].name' | grep -E $REGEX))

  	((page++))
    done

    TAGS=$(printf '%s\n' "${tags[@]}")

    for TAG in $TAGS; do
    	echo "    Deleting image: $REGISTRY_URL/$GROUP/$PROJECT_NAME:$TAG"
	SHA=$(curl --silent -H "Authorization: Bearer $PULL" -H "Accept: application/vnd.docker.distribution.manifest.v2+json" $REGISTRY_URL/v2/$GROUP/$PROJECT_NAME/manifests/$TAG | jq -r '.config.digest')
	echo $SHA
	curl -X DELETE -H "Authorization: Bearer $DEL" $REGISTRY_URL/v2/$GROUP/$PROJECT_NAME/manifests/$SHA
	exit
    done
  done
done

echo "Cleanup completed for group: $GROUP"
