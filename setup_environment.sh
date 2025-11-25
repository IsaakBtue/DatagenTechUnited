#!/bin/bash
# Techunited Data Generation - Automated Environment Setup
# This script automates the environment creation and package installation

set -e  # Exit on error

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}=================================================${NC}"
echo -e "${BLUE}  Techunited Data Generation Setup${NC}"
echo -e "${BLUE}=================================================${NC}"
echo ""

# Get script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

# Check if conda is installed
if ! command -v conda &> /dev/null; then
    echo -e "${RED}✗ Conda not found!${NC}"
    echo "Please install Anaconda or Miniconda first:"
    echo "  https://docs.conda.io/en/latest/miniconda.html"
    exit 1
fi

echo -e "${GREEN}✓ Conda found${NC}"
echo ""

# Check if environment already exists
ENV_NAME="HumanoidDataGeneration"
if conda env list | grep -q "^${ENV_NAME} "; then
    echo -e "${YELLOW}⚠ Environment '${ENV_NAME}' already exists${NC}"
    read -p "Do you want to remove it and recreate? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "Removing existing environment..."
        conda env remove -n ${ENV_NAME} -y
    else
        echo "Keeping existing environment. Skipping creation."
        SKIP_ENV_CREATE=true
    fi
fi

# Create conda environment
if [ "$SKIP_ENV_CREATE" != "true" ]; then
    echo ""
    echo -e "${BLUE}Step 1: Creating conda environment '${ENV_NAME}'...${NC}"
    conda create -y -n ${ENV_NAME} python=3.10
    echo -e "${GREEN}✓ Environment created${NC}"
fi

# Activate environment
echo ""
echo -e "${BLUE}Step 2: Activating environment...${NC}"
eval "$(conda shell.bash hook)"
conda activate ${ENV_NAME}
echo -e "${GREEN}✓ Environment activated${NC}"

# Install GVHMR
echo ""
echo -e "${BLUE}Step 3: Installing GVHMR...${NC}"
cd GVHMR
pip install -r requirements.txt
pip install -e .
cd ..
echo -e "${GREEN}✓ GVHMR installed${NC}"

# Install GMR
echo ""
echo -e "${BLUE}Step 4: Installing GMR...${NC}"
pip install -e .
echo -e "${GREEN}✓ GMR installed${NC}"

# Install libstdcxx
echo ""
echo -e "${BLUE}Step 5: Installing rendering dependencies...${NC}"
conda install -c conda-forge libstdcxx-ng -y
echo -e "${GREEN}✓ Rendering dependencies installed${NC}"

# Create necessary directories
echo ""
echo -e "${BLUE}Step 6: Creating directory structure...${NC}"
mkdir -p data
mkdir -p videos
mkdir -p outputs
mkdir -p GVHMR/inputs/checkpoints/body_models/smplx
mkdir -p GVHMR/inputs/checkpoints/body_models/smpl
mkdir -p GVHMR/inputs/checkpoints/gvhmr
mkdir -p GVHMR/inputs/checkpoints/hmr2
mkdir -p GVHMR/inputs/checkpoints/vitpose
mkdir -p GVHMR/inputs/checkpoints/yolo
mkdir -p GVHMR/outputs
echo -e "${GREEN}✓ Directories created${NC}"

# Summary
echo ""
echo -e "${GREEN}=================================================${NC}"
echo -e "${GREEN}  Installation Complete!${NC}"
echo -e "${GREEN}=================================================${NC}"
echo ""
echo "Environment: ${ENV_NAME}"
echo "Python: $(python --version)"
echo ""
echo ""
echo -e "${BLUE}Step 7: Reinstalling GMR with fixes...${NC}"
cd "$SCRIPT_DIR"
pip uninstall general-motion-retargeting -y > /dev/null 2>&1 || true
pip install -e . > /dev/null 2>&1
echo -e "${GREEN}✓ GMR reinstalled${NC}"

echo ""
echo -e "${YELLOW}=================================================${NC}"
echo -e "${YELLOW}  IMPORTANT: Manual Downloads Required${NC}"
echo -e "${YELLOW}=================================================${NC}"
echo ""
echo -e "${RED}⚠ SMPL/SMPL-X models CANNOT be uploaded to GitHub${NC}"
echo -e "${RED}  due to licensing restrictions!${NC}"
echo ""
echo "You MUST download these manually:"
echo ""
echo "1. SMPL-X Body Models"
echo "   - Register at: https://smpl-x.is.tue.mpg.de/"
echo "   - Download: SMPLX_NEUTRAL.npz, SMPLX_MALE.npz, SMPLX_FEMALE.npz"
echo "   - Place in: GVHMR/inputs/checkpoints/body_models/smplx/"
echo ""
echo "2. SMPL Body Models"
echo "   - Register at: https://smpl.is.tue.mpg.de/"
echo "   - Download: SMPL_NEUTRAL.pkl, SMPL_MALE.pkl, SMPL_FEMALE.pkl"
echo "   - Place in: GVHMR/inputs/checkpoints/body_models/smpl/"
echo ""
echo "3. GVHMR Checkpoints"
echo "   - Download: https://drive.google.com/drive/folders/1eebJ13FUEXrKBawHpJroW0sNSxLjh9xD"
echo "   - Place in: GVHMR/inputs/checkpoints/{gvhmr,hmr2,vitpose,yolo}/"
echo ""
echo -e "${GREEN}=================================================${NC}"
echo -e "${GREEN}  Next Steps${NC}"
echo -e "${GREEN}=================================================${NC}"
echo ""
echo "1. Download the models above (required)"
echo "2. Run: ./verify_installation.sh"
echo "3. Run: ./run_pipeline.sh --video /path/to/video.mp4"
echo ""
echo -e "${BLUE}Note: See MODEL_LICENSING.md for why models can't be in GitHub${NC}"
echo ""
echo -e "${GREEN}Setup script completed successfully!${NC}"

