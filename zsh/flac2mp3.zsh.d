# Advanced FLAC to MP3 converter with options

# Default settings
BITRATE="320k"
QUALITY=2  # 0=highest quality, slowest to 9=lowest quality, fastest
DELETE_ORIGINAL=false
OUTPUT_DIR=""

# Help function
show_help() {
    cat << EOF
Usage: $0 [options] [directory|files...]

Convert FLAC files to MP3 preserving all metadata

Options:
  -b, --bitrate RATE     Set MP3 bitrate (default: 320k)
                         Options: 128k, 192k, 256k, 320k
  -q, --quality LEVEL    Encoding quality 0-9 (default: 2)
                         0=best quality (slow), 9=fastest (lower quality)
  -o, --output DIR       Output directory for MP3 files
  -d, --delete-original  Delete FLAC files after successful conversion
  -h, --help             Show this help message

Examples:
  $0                     # Convert all FLAC in current directory
  $0 -b 256k -q 0        # High quality encoding with 256k bitrate
  $0 ~/Music/Albums      # Convert FLAC files in specified directory
  $0 -o ~/Music/MP3 *.flac  # Convert specific files to output directory
EOF
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -b|--bitrate)
            BITRATE="$2"
            shift 2
            ;;
        -q|--quality)
            QUALITY="$2"
            shift 2
            ;;
        -o|--output)
            OUTPUT_DIR="$2"
            shift 2
            ;;
        -d|--delete-original)
            DELETE_ORIGINAL=true
            shift
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        -*)
            echo "Unknown option: $1"
            show_help
            exit 1
            ;;
        *)
            break
            ;;
    esac
done

# Check for ffmpeg
if ! command -v ffmpeg &> /dev/null; then
    echo "Error: ffmpeg is not installed" >&2
    exit 1
fi

# Get input files/directories
if [[ $# -eq 0 ]]; then
    # Current directory
    SOURCES=(".")
else
    SOURCES=("$@")
fi

# Function to convert a single file
convert_file() {
    local flac="$1"
    local output_dir="${2:-$(dirname "$flac")}"
    local flac_dir="$(dirname "$flac")"
    
    # Create output directory if it doesn't exist
    mkdir -p "$output_dir"
    
    # Get filename without extension
    local base="$(basename "$flac" .flac)"
    
    # Determine output path
    if [[ "$output_dir" == "$flac_dir" ]]; then
        local output="$output_dir/$base.mp3"
    else
        # Preserve directory structure if converting to different location
        local relative_path="${flac#$PWD/}"
        local output="$output_dir/$base.mp3"
    fi
    
    echo "Converting: $flac"
    
    # Convert with metadata preservation
    ffmpeg -i "$flac" \
        -codec:a libmp3lame \
        -b:a "$BITRATE" \
        -q:a "$QUALITY" \
        -map_metadata 0 \
        -id3v2_version 3 \
        -write_id3v1 1 \
        "$output" 2>/dev/null
    
    if [[ $? -eq 0 ]]; then
        echo "✓ Created: $output"
        return 0
    else
        echo "✗ Failed: $flac" >&2
        return 1
    fi
}

# Process all sources
TOTAL=0
SUCCESS=0

for source in "${SOURCES[@]}"; do
    if [[ -f "$source" && "$source" == *.flac ]]; then
        # Single file
        ((TOTAL++))
        if convert_file "$source" "$OUTPUT_DIR"; then
            ((SUCCESS++))
            if $DELETE_ORIGINAL; then
                rm "$source"
                echo "  Deleted original: $source"
            fi
        fi
    elif [[ -d "$source" ]]; then
        # Directory - find all flac files
        local files=($source/**/*.flac(N))
        if [[ ${#files[@]} -eq 0 ]]; then
            echo "No FLAC files found in: $source"
            continue
        fi
        
        echo "Found ${#files[@]} FLAC file(s) in: $source"
        
        for flac in "${files[@]}"; do
            ((TOTAL++))
            if convert_file "$flac" "$OUTPUT_DIR"; then
                ((SUCCESS++))
                if $DELETE_ORIGINAL; then
                    rm "$flac"
                    echo "  Deleted original: $flac"
                fi
            fi
        done
    else
        echo "Skipping invalid source: $source" >&2
    fi
done

echo ""
echo "Conversion complete!"
echo "Successfully converted: $SUCCESS/$TOTAL files"
