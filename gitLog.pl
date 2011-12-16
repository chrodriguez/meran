#!/bin/bash
git log  --pretty=oneline --grep="HOTFIX" --all  --since="$1 days ago" | cut -c42-1000 | awk '!x[$0]++'
git log  --pretty=oneline --grep="CHANGELOG" --all  --since="$1 days ago" | cut -c42-1000 | awk '!x[$0]++'
