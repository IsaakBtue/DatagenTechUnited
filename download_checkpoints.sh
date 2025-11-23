#!/bin/bash
# Download GVHMR checkpoints from Google Drive
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

echo -e "${GREEN}Starting GVHMR checkpoint downloads...${NC}"
echo ""
echo "This will download approximately 10GB of model files."
echo "Source: https://drive.google.com/drive/folders/1eebJ13FUEXrKBawHpJroW0sNSxLjh9xD"
echo ""

# Ask for confirmation
read -p "Continue with download? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Download cancelled."
    echo ""
    echo "To download manually:"
    echo "  1. Visit: https://drive.google.com/drive/folders/1eebJ13FUEXrKBawHpJroW0sNSxLjh9xD"
    echo "  2. Download these files:"
    echo "     - gvhmr_siga24_release.ckpt → GVHMR/inputs/checkpoints/gvhmr/"
    echo "     - epoch=10-step=25000.ckpt → GVHMR/inputs/checkpoints/hmr2/"
    echo "     - vitpose-h-multi-coco.pth → GVHMR/inputs/checkpoints/vitpose/"
    echo "     - yolov8x.pt → GVHMR/inputs/checkpoints/yolo/"
    echo "     - dpvo.pth → GVHMR/inputs/checkpoints/dpvo/ (optional)"
    exit 0
fi

echo ""
echo -e "${BLUE}Downloading checkpoints from Google Drive...${NC}"
echo ""

# Function to download with progress
download_file() {
    local file_id="$1"
    local output_path="$2"
    local file_name=$(basename "$output_path")
    
    if [ -f "$output_path" ]; then
        echo -e "${YELLOW}⚠${NC} $file_name already exists, skipping..."
        return 0
    fi
    
    echo -e "${BLUE}Downloading $file_name...${NC}"
    
    # Try to download using gdown
    if gdown "https://drive.google.com/uc?id=$file_id" -O "$output_path" 2>&1; then
        if [ -f "$output_path" ]; then
            file_size=$(du -h "$output_path" | cut -f1)
            echo -e "${GREEN}✓${NC} Downloaded $file_name ($file_size)"
            return 0
        fi
    fi
    
    echo -e "${RED}✗${NC} Failed to download $file_name"
    echo "    Please download manually from:"
    echo "    https://drive.google.com/drive/folders/1eebJ13FUEXrKBawHpJroW0sNSxLjh9xD"
    return 1
}

# Try to download the entire folder (may require manual intervention)
echo "Attempting to download from Google Drive folder..."
echo "Note: If this fails, you'll need to download files manually."
echo ""

# Try using gdown to download the entire folder
cd GVHMR/inputs/checkpoints
if gdown --folder "https://drive.google.com/drive/folders/1eebJ13FUEXrKBawHpJroW0sNSxLjh9xD" 2>&1 | tee /tmp/gdown_output.txt; then
    echo ""
    echo -e "${GREEN}✓ Download completed!${NC}"
else
    echo ""
    echo -e "${YELLOW}⚠ Automatic download failed or requires manual authentication.${NC}"
    echo ""
    echo "Please download manually:"
    echo ""
    echo "1. Visit: https://drive.google.com/drive/folders/1eebJ13FUEXrKBawHpJroW0sNSxLjh9xD"
    echo ""
    echo "2. Download these files and place them in the correct directories:"
    echo ""
    echo "   Required files:"
    echo "   ├─ gvhmr_siga24_release.ckpt → GVHMR/inputs/checkpoints/gvhmr/"
    echo "   ├─ epoch=10-step=25000.ckpt → GVHMR/inputs/checkpoints/hmr2/"
    echo "   ├─ vitpose-h-multi-coco.pth → GVHMR/inputs/checkpoints/vitpose/"
    echo "   ├─ yolov8x.pt → GVHMR/inputs/checkpoints/yolo/"
    echo "   └─ dpvo.pth → GVHMR/inputs/checkpoints/dpvo/ (optional)"
    echo ""
    echo "3. After downloading, verify with: ./verify_installation.sh"
    cd "$SCRIPT_DIR"
    exit 1
fi

cd "$SCRIPT_DIR"

# Verify downloads
echo ""
echo -e "${BLUE}Verifying downloaded files...${NC}"
echo ""

files_ok=true

check_file() {
    local file_path="$1"
    local file_name=$(basename "$file_path")
    
    if [ -f "$file_path" ]; then
        file_size=$(du -h "$file_path" | cut -f1)
        echo -e "${GREEN}✓${NC} $file_name ($file_size)"
    else
        echo -e "${RED}✗${NC} $file_name (missing)"
        files_ok=false
    fi
}

check_file "GVHMR/inputs/checkpoints/gvhmr/gvhmr_siga24_release.ckpt"
check_file "GVHMR/inputs/checkpoints/hmr2/epoch=10-step=25000.ckpt"
check_file "GVHMR/inputs/checkpoints/vitpose/vitpose-h-multi-coco.pth"
check_file "GVHMR/inputs/checkpoints/yolo/yolov8x.pt"

if [ "$files_ok" = true ]; then
    echo ""
    echo -e "${GREEN}=================================================${NC}"
    echo -e "${GREEN}  All checkpoints downloaded successfully! ✓${NC}"
    echo -e "${GREEN}=================================================${NC}"
    echo ""
    echo "Next step: Run ./verify_installation.sh"
else
    echo ""
    echo -e "${YELLOW}=================================================${NC}"
    echo -e "${YELLOW}  Some files are missing${NC}"
    echo -e "${YELLOW}=================================================${NC}"
    echo ""
    echo "Please download missing files from:"
    echo "https://drive.google.com/drive/folders/1eebJ13FUEXrKBawHpJroW0sNSxLjh9xD"
    exit 1
fi
