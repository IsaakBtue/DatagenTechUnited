#!/bin/bash
# Download all required models and checkpoints from Google Drive

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}=================================================${NC}"
echo -e "${BLUE}  Complete Model & Checkpoint Downloader${NC}"
echo -e "${BLUE}=================================================${NC}"
echo ""

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Check if gdown is installed
if ! command -v gdown &> /dev/null; then
    echo -e "${YELLOW}Installing gdown for Google Drive downloads...${NC}"
    pip install gdown -q
fi

# Create all necessary directories
mkdir -p GVHMR/inputs/checkpoints/{gvhmr,hmr2,vitpose,yolo,dpvo}
mkdir -p GVHMR/inputs/checkpoints/body_models/{smpl,smplx}

echo -e "${GREEN}This script will download ALL required models:${NC}"
echo ""
echo "  1. Body Models (SMPL/SMPL-X) - ~500MB"
echo "  2. GVHMR Checkpoints - ~10GB"
echo ""
echo "Total download size: ~10.5GB"
echo ""

# Ask for confirmation
read -p "Continue with download? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Download cancelled."
    exit 0
fi

echo ""
echo -e "${BLUE}=================================================${NC}"
echo -e "${BLUE}  Step 1/2: Downloading Body Models${NC}"
echo -e "${BLUE}=================================================${NC}"
echo ""

# Download body_models folder
echo -e "${BLUE}Downloading SMPL/SMPL-X body models...${NC}"
cd GVHMR/inputs/checkpoints
if gdown --folder "https://drive.google.com/drive/folders/1J6lsvquyDFxZjjeSXo-Q57d82mKCVkn0" --remaining-ok 2>&1; then
    echo ""
    
    # Move body_models folder content if needed
    if [ -d "body_models" ]; then
        echo -e "${GREEN}✓ Body models downloaded!${NC}"
    else
        # Try to find and organize body_models files
        find . -name "SMPL*.pkl" -exec mv {} body_models/smpl/ \; 2>/dev/null || true
        find . -name "SMPL*.npz" -exec mv {} body_models/smplx/ \; 2>/dev/null || true
    fi
else
    echo -e "${YELLOW}⚠ Automatic download may need manual completion${NC}"
fi

cd "$SCRIPT_DIR"

echo ""
echo -e "${BLUE}=================================================${NC}"
echo -e "${BLUE}  Step 2/2: Downloading GVHMR Checkpoints${NC}"
echo -e "${BLUE}=================================================${NC}"
echo ""

# Download GVHMR checkpoints
echo -e "${BLUE}Downloading GVHMR checkpoint files...${NC}"
cd GVHMR/inputs/checkpoints

if gdown --folder "https://drive.google.com/drive/folders/1eebJ13FUEXrKBawHpJroW0sNSxLjh9xD" --remaining-ok 2>&1; then
    echo ""
    
    # Move files to correct locations if they were downloaded to wrong places
    find . -name "gvhmr_siga24_release.ckpt" -exec mv {} gvhmr/ \; 2>/dev/null || true
    find . -name "epoch=10-step=25000.ckpt" -exec mv {} hmr2/ \; 2>/dev/null || true
    find . -name "vitpose-h-multi-coco.pth" -exec mv {} vitpose/ \; 2>/dev/null || true
    find . -name "yolov8x.pt" -exec mv {} yolo/ \; 2>/dev/null || true
    find . -name "dpvo.pth" -exec mv {} dpvo/ \; 2>/dev/null || true
    
    # Clean up any extra directories created by gdown
    find . -type d -empty -delete 2>/dev/null || true
    
    echo -e "${GREEN}✓ Checkpoints downloaded!${NC}"
else
    echo -e "${YELLOW}⚠ Automatic download encountered issues${NC}"
fi

cd "$SCRIPT_DIR"

# Verify all downloads
echo ""
echo -e "${BLUE}=================================================${NC}"
echo -e "${BLUE}  Verifying Downloads${NC}"
echo -e "${BLUE}=================================================${NC}"
echo ""

download_success=0
download_failed=0

check_file() {
    local file_path="$1"
    local file_name=$(basename "$file_path")
    local category="$2"
    
    if [ -f "$file_path" ]; then
        file_size=$(du -h "$file_path" | cut -f1)
        echo -e "${GREEN}✓${NC} [$category] $file_name ($file_size)"
        ((download_success++))
    else
        echo -e "${RED}✗${NC} [$category] $file_name (missing)"
        ((download_failed++))
        return 1
    fi
    return 0
}

echo "Body Models:"
check_file "GVHMR/inputs/checkpoints/body_models/smpl/SMPL_NEUTRAL.pkl" "SMPL"
check_file "GVHMR/inputs/checkpoints/body_models/smpl/SMPL_MALE.pkl" "SMPL"
check_file "GVHMR/inputs/checkpoints/body_models/smpl/SMPL_FEMALE.pkl" "SMPL"
check_file "GVHMR/inputs/checkpoints/body_models/smplx/SMPLX_NEUTRAL.npz" "SMPL-X"
check_file "GVHMR/inputs/checkpoints/body_models/smplx/SMPLX_MALE.npz" "SMPL-X"
check_file "GVHMR/inputs/checkpoints/body_models/smplx/SMPLX_FEMALE.npz" "SMPL-X"

echo ""
echo "GVHMR Checkpoints:"
check_file "GVHMR/inputs/checkpoints/gvhmr/gvhmr_siga24_release.ckpt" "GVHMR"
check_file "GVHMR/inputs/checkpoints/hmr2/epoch=10-step=25000.ckpt" "HMR2"
check_file "GVHMR/inputs/checkpoints/vitpose/vitpose-h-multi-coco.pth" "VitPose"
check_file "GVHMR/inputs/checkpoints/yolo/yolov8x.pt" "YOLO"

echo ""

# Final status
if [ $download_failed -eq 0 ]; then
    echo -e "${GREEN}=================================================${NC}"
    echo -e "${GREEN}  ✓ All models downloaded successfully!${NC}"
    echo -e "${GREEN}=================================================${NC}"
    echo ""
    echo "Downloaded: $download_success files"
    echo ""
    echo "Next step: Run ./verify_installation.sh"
    exit 0
else
    echo -e "${YELLOW}=================================================${NC}"
    echo -e "${YELLOW}  ⚠ Some files need manual download${NC}"
    echo -e "${YELLOW}=================================================${NC}"
    echo ""
    echo "Success: $download_success files"
    echo "Missing: $download_failed files"
    echo ""
    echo "Manual download instructions:"
    echo ""
    
    if [ ! -f "GVHMR/inputs/checkpoints/body_models/smpl/SMPL_NEUTRAL.pkl" ] || \
       [ ! -f "GVHMR/inputs/checkpoints/body_models/smpl/SMPL_MALE.pkl" ] || \
       [ ! -f "GVHMR/inputs/checkpoints/body_models/smpl/SMPL_FEMALE.pkl" ] || \
       [ ! -f "GVHMR/inputs/checkpoints/body_models/smplx/SMPLX_NEUTRAL.npz" ] || \
       [ ! -f "GVHMR/inputs/checkpoints/body_models/smplx/SMPLX_MALE.npz" ] || \
       [ ! -f "GVHMR/inputs/checkpoints/body_models/smplx/SMPLX_FEMALE.npz" ]; then
        echo "Body Models:"
        echo "  Visit: https://drive.google.com/drive/folders/1J6lsvquyDFxZjjeSXo-Q57d82mKCVkn0"
        echo "  Download the body_models folder and place in: GVHMR/inputs/checkpoints/"
        echo ""
    fi
    
    if [ ! -f "GVHMR/inputs/checkpoints/gvhmr/gvhmr_siga24_release.ckpt" ] || \
       [ ! -f "GVHMR/inputs/checkpoints/hmr2/epoch=10-step=25000.ckpt" ] || \
       [ ! -f "GVHMR/inputs/checkpoints/vitpose/vitpose-h-multi-coco.pth" ] || \
       [ ! -f "GVHMR/inputs/checkpoints/yolo/yolov8x.pt" ]; then
        echo "GVHMR Checkpoints:"
        echo "  Visit: https://drive.google.com/drive/folders/1eebJ13FUEXrKBawHpJroW0sNSxLjh9xD"
        echo "  Download missing checkpoint files to their respective folders"
        echo ""
    fi
    
    echo "After downloading missing files, run: ./verify_installation.sh"
    exit 1
fi
