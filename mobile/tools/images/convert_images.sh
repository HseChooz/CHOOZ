#!/usr/bin/env bash
set -e

input_formats="png|jpg|jpeg"
output_format="heic"

# Help
print_help() {
cat << EOF
USAGE: ./convert_images.sh [-i path_to_image] | [-d path_to_directory]

OPTIONS:
    -i             Convert single image from PNG, JPG, JPEG to HEIC.
    -d             Recursively convert all PNG, JPG, JPEG images to HEIC inside directory.
    -h             Show help for this command.

EOF
}

# Read arguemnts
while getopts :hi:d: opt; do
    case $opt in
        h)
            print_help
            exit 0
            ;;
        i)
            image=$OPTARG
            ;;
        d)
            dir=$OPTARG
            ;;
        *)
            echo "❌ Unknown option: $OPTARG"
            print_help
            exit 1
            ;;
    esac
done

# Check arguments
if [[ -nz $image ]] && [[ -nz $dir ]]; then
    echo "❌ Expected only one argument -i | -d"
    exit 1
fi

# Image converter
convert_image() {
    input=$1
    output="${input%.*}.$output_format"

    sips -s format $output_format -s formatOptions 80 "$input" --out "$output" > /dev/null

    if [[ -e $output ]]; then
        rm "$input"
        echo "✅ Image is converted: $input"
    else
        echo "❌ Image is not converted: $input"
    fi
}

# Convert single image
if [[ -nz $image ]]; then
    if ! [[ -e $image ]]; then
        echo "❌ Image not exists: $image"
        exit 1
    fi
    if ! [[ "${image##*.}" =~ $input_formats ]]; then
        echo "❌ Incorrect image format: $image. Expected: $input_formats"
        exit 1
    fi
    convert_image "$image"
    exit 0
fi

# Convert images in a directory
if [[ -nz $dir ]]; then
    if ! [[ -e $dir ]]; then
        echo "❌ Directory not exists: $dir"
        exit 1
    fi
    find -E "$dir" -regex ".*\.($input_formats)" -print0 | while read -d $'\0' image
    do
        convert_image "$image"
    done
    exit 0
fi
