#!/bin/bash
# Download all required models and checkpoints from Google Drive

set -e

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

echo "================================================="
echo "  Complete Model & Checkpoint Downloader"
echo "================================================="
echo ""

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Check if gdown is installed
if ! command -v gdown &> /dev/null; then
    echo "Installing gdown for Google Drive downloads..."
    pip install gdown -q
fi

# Create all necessary directories
mkdir -p GVHMR/inputs/checkpoints/{gvhmr,hmr2,vitpose,yolo,dpvo}
mkdir -p GVHMR/inputs/checkpoints/body_models/{smpl,smplx}
mkdir -p data

echo -e "${GREEN}This script will download ALL required models:${NC}"
echo ""
echo "  1. Body Models (SMPL/SMPL-X) - ~500MB"
echo "  2. Sample Video (intercept1.mp4) - ~50MB"
echo "  3. GVHMR Checkpoints - ~10GB"
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
echo "Step 1/3: Downloading Body Models & Sample Video"
echo ""

# Download body_models folder and sample video
echo "Downloading from Google Drive..."
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"

if gdown --folder "https://drive.google.com/drive/folders/1J6lsvquyDFxZjjeSXo-Q57d82mKCVkn0" --remaining-ok 2>&1; then
    echo ""
    echo -e "${GREEN}✓ Download completed!${NC}"
    echo ""
    echo "Organizing files..."
    
    # Find and move the body_models folder (it might be in a subfolder created by gdown)
    BODY_MODELS_DIR=$(find . -type d -name "body_models" | head -n 1)
    if [ -n "$BODY_MODELS_DIR" ]; then
        # Copy the entire body_models directory structure
        cp -r "$BODY_MODELS_DIR"/* "$SCRIPT_DIR/GVHMR/inputs/checkpoints/body_models/"
        echo -e "${GREEN}✓${NC} Body models organized"
    else
        # Fallback: find individual SMPL files
        find . -name "SMPL*.pkl" -exec cp {} "$SCRIPT_DIR/GVHMR/inputs/checkpoints/body_models/smpl/" \; 2>/dev/null || true
        find . -name "SMPL*.npz" -exec cp {} "$SCRIPT_DIR/GVHMR/inputs/checkpoints/body_models/smplx/" \; 2>/dev/null || true
        echo -e "${RED}⚠${NC} Body models organized (fallback method)"
    fi
    
    # Find and move the sample video
    SAMPLE_VIDEO=$(find . -name "intercept1.mp4" -o -name "Intercept1.mp4" | head -n 1)
    if [ -n "$SAMPLE_VIDEO" ]; then
        cp "$SAMPLE_VIDEO" "$SCRIPT_DIR/data/intercept1.mp4"
        echo -e "${GREEN}✓${NC} Sample video moved to data/intercept1.mp4"
    fi
    
else
    echo -e "${RED}⚠ Automatic download encountered issues${NC}"
fi

# Clean up temp directory
cd "$SCRIPT_DIR"
rm -rf "$TEMP_DIR"

echo ""
echo "Step 2/3: Downloading GVHMR Checkpoints"
echo ""

# Download GVHMR checkpoints
echo "Downloading GVHMR checkpoint files..."
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"

if gdown --folder "https://drive.google.com/drive/folders/1eebJ13FUEXrKBawHpJroW0sNSxLjh9xD" --remaining-ok 2>&1; then
    echo ""
    echo -e "${GREEN}✓ Download completed!${NC}"
    echo ""
    echo "Organizing files..."
    
    # Find and move checkpoint files
    find . -name "gvhmr_siga24_release.ckpt" -exec cp {} "$SCRIPT_DIR/GVHMR/inputs/checkpoints/gvhmr/" \; 2>/dev/null || true
    find . -name "epoch=10-step=25000.ckpt" -exec cp {} "$SCRIPT_DIR/GVHMR/inputs/checkpoints/hmr2/" \; 2>/dev/null || true
    find . -name "vitpose-h-multi-coco.pth" -exec cp {} "$SCRIPT_DIR/GVHMR/inputs/checkpoints/vitpose/" \; 2>/dev/null || true
    find . -name "yolov8x.pt" -exec cp {} "$SCRIPT_DIR/GVHMR/inputs/checkpoints/yolo/" \; 2>/dev/null || true
    find . -name "dpvo.pth" -exec cp {} "$SCRIPT_DIR/GVHMR/inputs/checkpoints/dpvo/" \; 2>/dev/null || true
    
    echo -e "${GREEN}✓${NC} Checkpoints organized"
else
    echo -e "${RED}⚠ Automatic download encountered issues${NC}"
fi

# Clean up temp directory
cd "$SCRIPT_DIR"
rm -rf "$TEMP_DIR"

# Verify all downloads
echo ""
echo "Step 3/3: Verifying Downloads"
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
echo "Sample Video:"
check_file "data/intercept1.mp4" "Video"

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
    echo -e "${RED}=================================================${NC}"
    echo -e "${RED}  ⚠ Some files need manual download${NC}"
    echo -e "${RED}=================================================${NC}"
    echo ""
    echo "Success: $download_success files"
    echo "Missing: $download_failed files"
    exit 1
fi
