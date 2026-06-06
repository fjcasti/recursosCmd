#!/usr/bin/env bash

profiles=()
for f in "$HOME"/.gitconfig.*; do
    [[ -f "$f" ]] || continue
    ext="${f##*.gitconfig.}"
    [[ "$ext" == "gitconfig" ]] && continue
    profiles+=("$ext")
done

n=${#profiles[@]}

if [[ -z "$1" || "$1" -lt 1 || "$1" -gt "$n" ]] 2>/dev/null; then
    git_user=$(git config user.name 2>/dev/null)
    echo "Usuario Git: $git_user"
    for i in "${!profiles[@]}"; do
        mark=" "
        if cmp -s "$HOME/.gitconfig" "$HOME/.gitconfig.${profiles[$i]}"; then
            mark="*"
        fi
        echo "$((i+1)) [$mark] ${profiles[$i]}"
    done
else
    chosen="${profiles[$1-1]}"
    cp "$HOME/.gitconfig.$chosen" "$HOME/.gitconfig"
fi
