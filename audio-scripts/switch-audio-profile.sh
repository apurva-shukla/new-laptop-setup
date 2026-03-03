#!/usr/bin/env bash

set -euo pipefail

require_command() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "❌ Required command not found: $1" >&2
    exit 1
  fi
}

usage() {
  cat <<'EOF'
Usage: switch-audio-profile.sh <profile>

Profiles:
  webcam  - video call setup
  grado   - desk headphone setup
  mobile  - on-the-move setup
EOF
}

profile="${1:-}"

case "$profile" in
  webcam)
    profile_icon="📹"
    profile_name="Webcam"
    INPUT_DEVICES=(
      "Jabra Evolve2 85"
      "AS iPhone (2) Microphone"
      "MacBook Pro Microphone"
      "Beanies🫘"
    )
    OUTPUT_DEVICES=(
      "MacBook Pro Speakers"
      "Jabra Evolve2 85"
      "Beanies🫘"
    )
    ;;
  grado)
    profile_icon="🎧"
    profile_name="Grado"
    INPUT_DEVICES=(
      "MacBook Pro Microphone"
      "Jabra Evolve2 85"
      "AS iPhone (2) Microphone"
      "Beanies🫘"
    )
    OUTPUT_DEVICES=(
      "MacBook Pro Speakers"
      "Jabra Evolve2 85"
      "Beanies🫘"
    )
    ;;
  mobile)
    profile_icon="🚶"
    profile_name="Mobile"
    INPUT_DEVICES=(
      "Beanies🫘"
      "AS iPhone (2) Microphone"
      "MacBook Pro Microphone"
      "Jabra Evolve2 85"
    )
    OUTPUT_DEVICES=(
      "Beanies🫘"
      "MacBook Pro Speakers"
      "Jabra Evolve2 85"
    )
    ;;
  *)
    usage >&2
    exit 2
    ;;
esac

require_command "SwitchAudioSource"
require_command "grep"

available_inputs="$(SwitchAudioSource -a -t input)"
available_outputs="$(SwitchAudioSource -a -t output)"

pick_first_available() {
  local available="$1"
  shift
  local device=""
  for device in "$@"; do
    if printf '%s\n' "$available" | grep -Fqx -- "$device"; then
      printf '%s\n' "$device"
      return 0
    fi
  done
  return 1
}

selected_input=""
selected_output=""

if selected_input="$(pick_first_available "$available_inputs" "${INPUT_DEVICES[@]}")"; then
  SwitchAudioSource -t input -s "$selected_input"
fi

if selected_output="$(pick_first_available "$available_outputs" "${OUTPUT_DEVICES[@]}")"; then
  SwitchAudioSource -t output -s "$selected_output"
fi

if [ -n "$selected_input" ] && [ -n "$selected_output" ]; then
  echo "$profile_icon $profile_name: In→${selected_input} | Out→${selected_output}"
elif [ -n "$selected_input" ]; then
  echo "⚠️ Input: ${selected_input} | No output device found"
elif [ -n "$selected_output" ]; then
  echo "⚠️ No input device found | Output: ${selected_output}"
else
  echo "❌ No audio devices found"
fi
