#!/bin/bash
# Download GVHMR checkpoints automatically from Google Drive
# Note: SMPL/SMPL-X models CANNOT be downloaded automatically due to licensing

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}=================================================${NC}"
echo -e "${BLUE}  GVHMR Checkpoint Downloader${NC}"
echo -e "${BLUE}=================================================${NC}"
echo ""

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Check if gdown is installed
if ! command -v gdown &> /dev/null; then
    echo -e "${YELLOW}Installing gdown for Google Drive downloads...${NC}"
    pip install gdown -q
fi

# Create checkpoint directories
mkdir -p GVHMR/inputs/checkpoints/{gvhmr,hmr2,vitpose,yolo,dpvo}

echo -e "${GREEN}Downloading GVHMR checkpoints...${NC}"
echo ""

# Function to download with progress
download_file() {
    local gdrive_id="$1"
    local output_path="$2"
    local file_name=$(basename "$output_path")
    
    if [ -f "$output_path" ]; then
        echo -e "${YELLOW}⚠${NC} $file_name already exists, skipping..."
        return 0
    fi
    
    echo -e "${BLUE}Downloading $file_name...${NC}"
    gdown "$gdrive_id" -O "$output_path" --quiet
    
    if [ -f "$output_path" ]; then
        file_size=$(du -h "$output_path" | cut -f1)
        echo -e "${GREEN}✓${NC} Downloaded $file_name ($file_size)"
    else
        echo -e "${RED}✗${NC} Failed to download $file_name"
        return 1
    fi
}

# Google Drive file IDs from GVHMR repository
# You need to get these from: https://drive.google.com/drive/folders/1eebJ13FUEXrKBawHpJroW0sNSxLjh9xD

echo "Note: This script attempts to download GVHMR checkpoints."
echo "If downloads fail, please download manually from:"
echo "https://drive.google.com/drive/folders/1eebJ13FUEXrKBawHpJroW0sNSxLjh9xD"
echo ""

# These are placeholder IDs - you need to get actual file IDs from the GVHMR team
# To get file ID: Right click file in Google Drive → Share → Copy link
# Extract ID from: https://drive.google.com/file/d/FILE_ID/view

# Check if user wants to download
read -p "Attempt to download GVHMR checkpoints? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Skipping automatic download."
    echo "Please download manually and place in GVHMR/inputs/checkpoints/"
    exit 0
fi

# Note: Since we don't have direct IDs, we'll provide manual instructions
echo ""
echo -e "${YELLOW}⚠ Automatic download not configured yet${NC}"
echo ""
echo "Please download the following files manually from:"
echo "https://drive.google.com/drive/folders/1eebJ13FUEXrKBawHpJroW0sNSxLjh9xD"
echo ""
echo "Required files:"
echo "  1. gvhmr_siga24_release.ckpt → GVHMR/inputs/checkpoints/gvhmr/"
echo "  2. epoch=10-step=25000.ckpt → GVHMR/inputs/checkpoints/hmr2/"
echo "  3. vitpose-h-multi-coco.pth → GVHMR/inputs/checkpoints/vitpose/"
echo "  4. yolov8x.pt → GVHMR/inputs/checkpoints/yolo/"
echo "  5. dpvo.pth → GVHMR/inputs/checkpoints/dpvo/ (optional)"
echo ""
echo -e "${BLUE}After downloading, run: ./verify_installation.sh${NC}"

