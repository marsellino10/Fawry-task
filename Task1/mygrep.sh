#!/bin/bash

# Handle --help
if [[ "$1" == "--help" ]]; then
    echo "Usage: $0 [-n] [-v] <search_string> <file>"
    exit 0
fi

# Parse options
show_line_numbers=false
invert_match=false

while [[ "$#" -gt 0 ]]; do
    case "$1" in
        -n) show_line_numbers=true; shift ;;
        -v) invert_match=true; shift ;;
        -nv|-vn) 
            show_line_numbers=true
            invert_match=true
            shift ;;
        *) 
            if [[ -z "$search_string" ]]; then
                search_string="$1"
            else
                file="$1"
            fi
            shift ;;
    esac
done

# Validate inputs
if [[ -z "$search_string" || -z "$file" ]]; then
    echo "Error: Missing arguments. Use --help for usage." >&2
    exit 1
fi

if [[ ! -f "$file" ]]; then
    echo "Error: File '$file' not found." >&2
    exit 1
fi

# Search logic
line_number=0
while IFS= read -r line; do
    ((line_number++))
    
    # Case-insensitive match
    if [[ "${line,,}" == *"${search_string,,}"* ]]; then
        match=true
    else
        match=false
    fi

    # FIXED: Invert match logic
    if [[ "$invert_match" == true ]]; then
        if $match; then
            match=false
        else
            match=true
        fi
    fi

    # Print if matched
    if $match; then
        if $show_line_numbers; then
            printf "%d:" "$line_number"
        fi
        printf "%s\n" "$line"
    fi
done < "$file"
