#!/bin/bash

# This script generates content for the site

# Set the paths
ROOT="$(dirname "$(realpath -s "$0")")/.."
IDS="${ROOT}/data/ids.yml"
MD="${ROOT}/content/_index.md"

# Get the number of identities
N=$(yq eval '.ids | length' "${IDS}")

# Clear the markdown file
mkdir -p "${ROOT}/content"
echo -e "+++\n+++" >"${MD}"

# Get values from the ID object (#1) by key (#2) as a YAML string
get() {
  echo "$1" | yq eval "$2" -
}

# Check if the string is not empty or `null`
is_empty() {
  [ "$1" = "" ] || [ "$1" = "null" ]
}

# For each index of an ID
for ((i = 0; i < N; i++)); do
  # Get the identity
  ID=$(yq eval ".ids.$i" "${IDS}")

  # Get the name
  NAME=$(get "${ID}" .name)
  if is_empty "${NAME}"; then
    echo "[WARNING] Skipping item #$i: no name provided."
    continue
  fi
  # Append the name to the markdown file
  echo -e "\n# ${NAME}" >>"${MD}"

  # Get the adjectives
  NEGATIVE_ADJECTIVES=$(get "${ID}" .adjectives.negative)
  NEUTRAL_ADJECTIVES=$(get "${ID}" .adjectives.neutral)
  POSITIVE_ADJECTIVES=$(get "${ID}" .adjectives.positive)
  # Combine the adjectives
  ADJECTIVES=""
  if ! is_empty "${POSITIVE_ADJECTIVES}"; then
    ADJECTIVES="${ADJECTIVES}\n\n### Positive\n${POSITIVE_ADJECTIVES}"
  fi
  if ! is_empty "${NEUTRAL_ADJECTIVES}"; then
    ADJECTIVES="${ADJECTIVES}\n\n### Neutral\n${NEUTRAL_ADJECTIVES}"
  fi
  if ! is_empty "${NEGATIVE_ADJECTIVES}"; then
    ADJECTIVES="${ADJECTIVES}\n\n### Negative\n${NEGATIVE_ADJECTIVES}"
  fi
  # If they have been provided, append the adjectives to the markdown file
  if ! is_empty "${ADJECTIVES}"; then
    echo -e "\n## Adjectives${ADJECTIVES}" >>"${MD}"
  fi

  # Get the assets

  # Get the number of video files
  VIDEO_N=$(get "${ID}" '.assets.videos | length')

  # Combine the videos
  VIDEOS=""
  for ((j = 0; j < VIDEO_N; j++)); do
    # Get the video
    VIDEO=$(get "${ID}" ".assets.videos.$j")
    # Get the title
    VIDEO_TITLE=$(get "${VIDEO}" .title)
    # Get the URLs
    VIDEO_URLS=$(get "${VIDEO}" .urls.[] |
      sed -r 's|(.*)|  - [\1](\1)|g' |
      sed -r 's|\[https:\/\/www.youtube.com.*\]|[YT]|g')
    # If these two fields have been provided, append the video
    if ! is_empty "${VIDEO_TITLE}" && ! is_empty "${VIDEO_URLS}"; then
      VIDEOS="${VIDEOS}\n- ${VIDEO_TITLE}\n${VIDEO_URLS}"
    fi
  done
  # If they have been provided, append the videos to the markdown file
  if ! is_empty "${VIDEOS}"; then
    echo -e "\n## Videos${VIDEOS}" >>"${MD}"
  fi

done
