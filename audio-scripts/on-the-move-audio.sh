#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title On the Move Audio
# @raycast.mode compact

# Optional parameters:
# @raycast.icon 🚶
# @raycast.packageName Audio

# Documentation:
# @raycast.description Switch to mobile/portable audio setup
# @raycast.author Apurva Shukla

# ============================================
# CONFIGURE YOUR DEVICE PRIORITY ORDER BELOW
# First available device in list will be used
# ============================================

# Input devices (microphone) - in priority order
INPUT_DEVICES=(
    "Beanies🫘"
    "AS iPhone (2) Microphone"
    "MacBook Pro Microphone"
    "Jabra Evolve2 85"
)

# Output devices (speakers/headphones) - in priority order
OUTPUT_DEVICES=(
    "Beanies🫘"
    "MacBook Pro Speakers"
    "Jabra Evolve2 85"
)

# ============================================
# SCRIPT LOGIC - NO NEED TO MODIFY BELOW
# ============================================

# Get list of available devices
available_inputs=$(SwitchAudioSource -a -t input)
available_outputs=$(SwitchAudioSource -a -t output)

# Find and set first available input device
input_set=false
for device in "${INPUT_DEVICES[@]}"; do
    if echo "$available_inputs" | grep -qF "$device"; then
        SwitchAudioSource -t input -s "$device"
        selected_input="$device"
        input_set=true
        break
    fi
done

# Find and set first available output device
output_set=false
for device in "${OUTPUT_DEVICES[@]}"; do
    if echo "$available_outputs" | grep -qF "$device"; then
        SwitchAudioSource -t output -s "$device"
        selected_output="$device"
        output_set=true
        break
    fi
done

# Report results
if $input_set && $output_set; then
    echo "🚶 Mobile: In→${selected_input} | Out→${selected_output}"
elif $input_set; then
    echo "⚠️ Input: ${selected_input} | No output device found"
elif $output_set; then
    echo "⚠️ No input device found | Output: ${selected_output}"
else
    echo "❌ No audio devices found"
fi
