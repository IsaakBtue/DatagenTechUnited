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

# Download each checkpoint from its respective subfolder
echo "Downloading checkpoints from Google Drive..."
echo "Note: Each file will be downloaded from its specific folder."
echo ""

# We'll try to download from each subfolder in the shared Google Drive
# Main folder: https://drive.google.com/drive/folders/1eebJ13FUEXrKBawHpJroW0sNSxLjh9xD
BASE_FOLDER="1eebJ13FUEXrKBawHpJroW0sNSxLjh9xD"

download_success=0
download_failed=0

# Try to download the entire folder structure with all subfolders
echo -e "${BLUE}Attempting to download all files...${NC}"
cd GVHMR/inputs/checkpoints

# Try downloading the folder with all contents recursively
if gdown --folder "https://drive.google.com/drive/folders/1eebJ13FUEXrKBawHpJroW0sNSxLjh9xD" --remaining-ok 2>&1; then
    echo ""
    
    # Move files to correct locations if they were downloaded to wrong places
    # Sometimes gdown downloads to a subfolder with the Drive folder name
    
    # Find and move files to correct locations
    find . -name "gvhmr_siga24_release.ckpt" -exec mv {} gvhmr/ \; 2>/dev/null || true
    find . -name "epoch=10-step=25000.ckpt" -exec mv {} hmr2/ \; 2>/dev/null || true
    find . -name "vitpose-h-multi-coco.pth" -exec mv {} vitpose/ \; 2>/dev/null || true
    find . -name "yolov8x.pt" -exec mv {} yolo/ \; 2>/dev/null || true
    find . -name "dpvo.pth" -exec mv {} dpvo/ \; 2>/dev/null || true
    
    # Clean up any extra directories created by gdown
    find . -type d -empty -delete 2>/dev/null || true
    
    echo -e "${GREEN}✓ Download completed!${NC}"
else
    echo ""
    echo -e "${YELLOW}⚠ Automatic download encountered issues.${NC}"
    echo "  This is normal for Google Drive shared folders."
    echo ""
fi

cd "$SCRIPT_DIR"

# Check what we managed to download
echo ""
echo -e "${BLUE}Checking downloaded files...${NC}"
echo ""

files_to_check=(
    "GVHMR/inputs/checkpoints/gvhmr/gvhmr_siga24_release.ckpt"
    "GVHMR/inputs/checkpoints/hmr2/epoch=10-step=25000.ckpt"
    "GVHMR/inputs/checkpoints/vitpose/vitpose-h-multi-coco.pth"
    "GVHMR/inputs/checkpoints/yolo/yolov8x.pt"
)

for file_path in "${files_to_check[@]}"; do
    if [ -f "$file_path" ]; then
        file_size=$(du -h "$file_path" | cut -f1)
        file_name=$(basename "$file_path")
        echo -e "${GREEN}✓${NC} $file_name ($file_size)"
        ((download_success++))
    else
        file_name=$(basename "$file_path")
        echo -e "${RED}✗${NC} $file_name (missing)"
        ((download_failed++))
    fi
done

# If any files are missing, provide manual instructions
if [ $download_failed -gt 0 ]; then
    echo ""
    echo -e "${YELLOW}=================================================${NC}"
    echo -e "${YELLOW}  Some files need to be downloaded manually${NC}"
    echo -e "${YELLOW}=================================================${NC}"
    echo ""
    echo "Please complete the download manually:"
    echo ""
    echo "1. Visit: https://drive.google.com/drive/folders/1eebJ13FUEXrKBawHpJroW0sNSxLjh9xD"
    echo ""
    echo "2. Navigate into each subfolder and download the files:"
    echo ""
    
    [ ! -f "GVHMR/inputs/checkpoints/gvhmr/gvhmr_siga24_release.ckpt" ] && \
        echo "   gvhmr/ folder → Download gvhmr_siga24_release.ckpt → GVHMR/inputs/checkpoints/gvhmr/"
    
    [ ! -f "GVHMR/inputs/checkpoints/hmr2/epoch=10-step=25000.ckpt" ] && \
        echo "   hmr2/ folder → Download epoch=10-step=25000.ckpt → GVHMR/inputs/checkpoints/hmr2/"
    
    [ ! -f "GVHMR/inputs/checkpoints/vitpose/vitpose-h-multi-coco.pth" ] && \
        echo "   vitpose/ folder → Download vitpose-h-multi-coco.pth → GVHMR/inputs/checkpoints/vitpose/"
    
    [ ! -f "GVHMR/inputs/checkpoints/yolo/yolov8x.pt" ] && \
        echo "   yolo/ folder → Download yolov8x.pt → GVHMR/inputs/checkpoints/yolo/"
    
    echo ""
    echo "3. Optional: dpvo/dpvo.pth (for advanced features)"
    echo ""
    echo "4. After downloading, verify with: ./verify_installation.sh"
    echo ""
    exit 1
fi

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
