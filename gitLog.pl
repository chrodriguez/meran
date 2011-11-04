#!/bin/bash
git log  --pretty=oneline --grep="CHANGELOG" --all  --since="31 days ago" | cut -c42-1000 | awk '!x[$0]++'
