#!/bin/bash

echo "Different date and time formats:"
echo "--------------------------------"

# Standard date and time
echo "Standard format: $(date)"

# ISO 8601 format
echo "ISO format: $(date -I)"

# Custom formats
echo "Time only (24-hour): $(date +"%H:%M:%S")"
echo "Time only (12-hour): $(date +"%I:%M:%S %p")"
echo "Date only (YMD): $(date +"%Y-%m-%d")"
echo "Date only (MDY): $(date +"%m/%d/%Y")"
echo "Day of week: $(date +"%A")"
echo "Month name: $(date +"%B")"
echo "Week number: $(date +"%V")"

# Timestamp
echo "Unix timestamp: $(date +%s)"

# Custom combined formats
echo "Custom format 1: $(date +"%Y-%m-%d at %H:%M:%S")"
echo "Custom format 2: $(date +"%A, %B %d, %Y - %I:%M %p")"
