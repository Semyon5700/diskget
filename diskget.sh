#!/bin/bash

# diskget - Utility to count files on mounted filesystems
# Copyright (C) 2025 Semyon5700
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

VERSION="1.0.0"
AUTHOR="Semyon5700"

show_help() {
    cat << EOF
Usage: diskget [OPTIONS]

Display file count statistics for mounted filesystems.

OPTIONS:
    -h, --help          Show this help message
    -v, --version       Show version information
    -d, --details       Show detailed information for each filesystem
    -s, --summary       Show only summary (default)
    --sort=size         Sort by filesystem size
    --sort=files        Sort by file count
    --sort=mount        Sort by mount point (default)
    --human-readable    Display sizes in human readable format (e.g., 1K, 234M, 2G)

EXAMPLES:
    diskget              # Basic summary
    diskget -d           # Detailed view
    diskget --sort=files # Sort by file count
    diskget --human-readable -d

EOF
}

show_version() {
    echo "diskget v$VERSION"
    echo "Copyright (C) 2025 $AUTHOR"
    echo "License GPLv3+: GNU GPL version 3 or later <https://gnu.org/licenses/gpl.html>"
    echo "This is free software: you are free to change and redistribute it."
    echo "There is NO WARRANTY, to the extent permitted by law."
}

# Default values
MODE="summary"
SORT_BY="mount"
HUMAN_READABLE=false

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -v|--version)
            show_version
            exit 0
            ;;
        -d|--details)
            MODE="details"
            shift
            ;;
        -s|--summary)
            MODE="summary"
            shift
            ;;
        --sort=*)
            SORT_BY="${1#*=}"
            shift
            ;;
        --human-readable)
            HUMAN_READABLE=true
            shift
            ;;
        *)
            echo "Error: Unknown option $1"
            echo "Try 'diskget --help' for more information."
            exit 1
            ;;
    esac
done

# Validate sort option
case $SORT_BY in
    size|files|mount) ;;
    *)
        echo "Error: Invalid sort option '$SORT_BY'"
        echo "Valid options: size, files, mount"
        exit 1
        ;;
esac

# Check if required tools are available
check_dependencies() {
    local deps=("df" "find" "awk")
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            echo "Error: Required tool '$dep' is not installed."
            exit 1
        fi
    done
}

format_size() {
    local bytes=$1
    if $HUMAN_READABLE; then
        echo "$bytes" | awk '{
            if ($1 >= 1099511627776) {
                printf "%.2fT", $1/1099511627776
            } else if ($1 >= 1073741824) {
                printf "%.2fG", $1/1073741824
            } else if ($1 >= 1048576) {
                printf "%.2fM", $1/1048576
            } else if ($1 >= 1024) {
                printf "%.2fK", $1/1024
            } else {
                printf "%d", $1
            }
        }'
    else
        echo "$bytes"
    fi
}

get_file_count() {
    local mount_point="$1"
    # Use find to count files, excluding some special filesystems
    if [[ "$mount_point" == "/dev" ]] || [[ "$mount_point" == "/proc" ]] || [[ "$mount_point" == "/sys" ]]; then
        echo "N/A"
    else
        local count
        count=$(find "$mount_point" -type f 2>/dev/null | wc -l)
        echo "$count"
    fi
}

get_filesystem_info() {
    # Get filesystem information using df, excluding temporary filesystems
    df -k --output=source,fstype,size,used,avail,pcent,target | \
    awk 'NR>1 && $6 !~ /^(devtmpfs|tmpfs|devfs|proc|sysfs|overlay|squashfs)/ {print $1","$2","$3","$4","$5","$6","$7}'
}

main() {
    check_dependencies
    
    declare -a results
    local total_files=0
    local total_size=0
    local total_used=0
    
    echo "Analyzing filesystems... This may take a while for large drives." >&2
    
    # Read filesystem information
    while IFS=',' read -r device fstype size_kb used_kb avail_kb percent mount_point; do
        # Skip problematic mount points
        [[ -z "$mount_point" ]] || [[ ! -d "$mount_point" ]] || [[ ! -r "$mount_point" ]] && continue
        
        file_count=$(get_file_count "$mount_point")
        
        if [[ "$file_count" != "N/A" ]]; then
            total_files=$((total_files + file_count))
            total_size=$((total_size + size_kb * 1024))
            total_used=$((total_used + used_kb * 1024))
        fi
        
        results+=("$device|$fstype|$size_kb|$used_kb|$avail_kb|$percent|$mount_point|$file_count")
    done < <(get_filesystem_info)
    
    # Sort results
    case $SORT_BY in
        size)
            IFS=$'\n' sorted_results=($(sort -t'|' -k3 -nr <<<"${results[*]}"))
            ;;
        files)
            IFS=$'\n' sorted_results=($(sort -t'|' -k8 -nr <<<"${results[*]}"))
            ;;
        mount)
            IFS=$'\n' sorted_results=($(sort -t'|' -k7 <<<"${results[*]}"))
            ;;
    esac
    
    # Display results
    if [[ "$MODE" == "details" ]]; then
        printf "%-20s %-10s %-12s %-12s %-12s %-6s %-15s %s\n" \
            "DEVICE" "TYPE" "SIZE" "USED" "AVAIL" "USE%" "MOUNT POINT" "FILES"
        echo "---------------------------------------------------------------------------------------------------"
        
        for result in "${sorted_results[@]}"; do
            IFS='|' read -r device fstype size_kb used_kb avail_kb percent mount_point file_count <<< "$result"
            
            size_display=$(format_size $((size_kb * 1024)))
            used_display=$(format_size $((used_kb * 1024)))
            avail_display=$(format_size $((avail_kb * 1024)))
            
            printf "%-20s %-10s %-12s %-12s %-12s %-6s %-15s %s\n" \
                "$(echo "$device" | cut -c1-19)" \
                "$(echo "$fstype" | cut -c1-9)" \
                "$size_display" \
                "$used_display" \
                "$avail_display" \
                "$percent" \
                "$(echo "$mount_point" | cut -c1-14)" \
                "$file_count"
        done
    else
        # Summary mode
        printf "%-15s %-12s %-12s %-6s %-15s %s\n" \
            "DEVICE" "SIZE" "USED" "USE%" "MOUNT POINT" "FILES"
        echo "-----------------------------------------------------------------------"
        
        for result in "${sorted_results[@]}"; do
            IFS='|' read -r device fstype size_kb used_kb avail_kb percent mount_point file_count <<< "$result"
            
            size_display=$(format_size $((size_kb * 1024)))
            used_display=$(format_size $((used_kb * 1024)))
            
            printf "%-15s %-12s %-12s %-6s %-15s %s\n" \
                "$(echo "$device" | cut -c1-14)" \
                "$size_display" \
                "$used_display" \
                "$percent" \
                "$(echo "$mount_point" | cut -c1-14)" \
                "$file_count"
        done
    fi
    
    # Show totals
    echo
    echo "SUMMARY:"
    echo "Total files across all filesystems: $(printf "%'d" $total_files)"
    echo "Total disk space: $(format_size $total_size)"
    echo "Total used space: $(format_size $total_used)"
}

# Run main function
main "$@"
