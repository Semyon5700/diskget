# DiskGet

A Linux command-line utility for comprehensive filesystem analysis and file counting.

DiskGet is a bash-based tool that provides detailed statistics about mounted filesystems, including file counts, disk usage, and storage allocation across all mounted partitions. It offers both summary and detailed views with multiple sorting options.

Features:
- File Counting: Recursively count files on all mounted filesystems
- Multiple Display Modes: Summary and detailed views
- Flexible Sorting: Sort by size, file count, or mount point
- Human-Readable Output: Optional human-readable size formatting
- Filesystem Filtering: Automatically excludes temporary and virtual filesystems
- Cross-Platform: Works on most Linux distributions

Quick Install:
```bash
git clone https://github.com/semyon5700/diskget.git
cd diskget
chmod +x install.sh
./install.sh
```

Manual Installation:
```bash
sudo cp diskget.sh /usr/local/bin/diskget
sudo chmod +x /usr/local/bin/diskget
```

Basic Usage:
```bash
diskget
diskget --details
diskget --sort=files
diskget --human-readable -d
diskget --help
diskget --version
```

Options:
- -h, --help - Show help message
- -v, --version - Show version information
- -d, --details - Show detailed filesystem information
- -s, --summary - Show summary view (default)
- --sort=size|files|mount - Sort output by specified field
- --human-readable - Display sizes in human-readable format

Examples:
```bash
diskget
diskget --details --sort=files --human-readable
diskget | grep "/home"
```

The utility displays: Device, Type, Size/Used/Avail, Use%, Mount Point, and File count.

Requirements: Linux operating system, Bash shell, Standard GNU utilities: df, find, awk

Copyright (C) 2025 Semyon5700

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program. If not, see <https://www.gnu.org/licenses/>.
```
