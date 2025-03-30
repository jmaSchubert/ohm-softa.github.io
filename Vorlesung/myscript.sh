#!/bin/bash

# Use sed to replace double slashes (//) with a single slash (/) in all .md files
find . -type f -name "*.md" -exec sed -i 's/\/\//\//g' {} +