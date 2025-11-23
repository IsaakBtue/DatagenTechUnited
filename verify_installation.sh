#!/bin/bash
# Techunited Data Generation - Installation Verification Script

echo "==================================================================="
echo "  Techunited Data Generation - Installation Verification"
echo "==================================================================="
echo ""

# Get the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

pass_count=0
fail_count=0

# Function to print check result
check_pass() {
    echo -e "   ${GREEN}✓${NC} $1"
    ((pass_count++))
}

check_fail() {
    echo -e "   ${RED}✗${NC} $1"
    ((fail_count++))
}

check_warn() {
    echo -e "   ${YELLOW}⚠${NC} $1"
}

# 1. Check conda environment
echo "1. Checking conda environment..."
if conda env list | grep -q "^gmr "; then
    check_pass "Environment 'gmr' exists"
else
    check_fail "Environment 'gmr' not found"
    echo "      Create it with: conda create -y -n gmr python=3.10"
fi

# Try to activate environment
if [ -f "$HOME/miniforge3/etc/profile.d/conda.sh" ]; then
    source "$HOME/miniforge3/etc/profile.d/conda.sh"
elif [ -f "$HOME/anaconda3/etc/profile.d/conda.sh" ]; then
    source "$HOME/anaconda3/etc/profile.d/conda.sh"
elif [ -f "$HOME/miniconda3/etc/profile.d/conda.sh" ]; then
    source "$HOME/miniconda3/etc/profile.d/conda.sh"
else
    CONDA_BASE=$(conda info --base 2>/dev/null)
    if [ -n "$CONDA_BASE" ]; then
        source "$CONDA_BASE/etc/profile.d/conda.sh"
    fi
fi
conda activate gmr 2>/dev/null

# 2. Check Python version
echo ""
echo "2. Checking Python version..."
python_version=$(python --version 2>&1)
if [[ $python_version == *"3.10"* ]]; then
    check_pass "Python version: $python_version"
else
    check_warn "Python version: $python_version (expected 3.10.x)"
fi

# 3. Check Python packages
echo ""
echo "3. Checking Python packages..."

python -c "import mujoco; print('MuJoCo version:', mujoco.__version__)" 2>/dev/null
if [ $? -eq 0 ]; then
    check_pass "MuJoCo installed"
else
    check_fail "MuJoCo not installed (pip install mujoco)"
fi

python -c "import torch; print('PyTorch version:', torch.__version__)" 2>/dev/null
if [ $? -eq 0 ]; then
    check_pass "PyTorch installed"
else
    check_fail "PyTorch not installed"
fi

python -c "import general_motion_retargeting" 2>/dev/null
if [ $? -eq 0 ]; then
    check_pass "GMR library installed"
else
    check_fail "GMR not installed (pip install -e .)"
fi

python -c "import smplx" 2>/dev/null
if [ $? -eq 0 ]; then
    check_pass "SMPLX library installed"
else
    check_fail "SMPLX not installed"
fi

# 4. Check CUDA
echo ""
echo "4. Checking CUDA support..."
cuda_available=$(python -c "import torch; print(torch.cuda.is_available())" 2>/dev/null)
if [ "$cuda_available" == "True" ]; then
    cuda_version=$(python -c "import torch; print(torch.version.cuda)" 2>/dev/null)
    check_pass "CUDA available (version: $cuda_version)"
else
    check_warn "CUDA not available (CPU only mode)"
fi

# 5. Check directory structure
echo ""
echo "5. Checking directory structure..."

[ -d "scripts" ] && check_pass "scripts/ folder exists" || check_fail "scripts/ folder missing"
[ -d "assets/booster_t1" ] && check_pass "assets/booster_t1/ folder exists" || check_fail "assets/booster_t1/ folder missing"
[ -d "GVHMR" ] && check_pass "GVHMR/ folder exists (included!)" || check_fail "GVHMR/ folder missing (should be included in repo)"
[ -d "general_motion_retargeting" ] && check_pass "general_motion_retargeting/ folder exists" || check_fail "general_motion_retargeting/ folder missing"
[ -d "data" ] && check_pass "data/ folder exists" || check_warn "data/ folder missing (will be created)"
[ -d "videos" ] && check_pass "videos/ folder exists" || check_warn "videos/ folder missing (will be created)"

# 6. Check critical scripts
echo ""
echo "6. Checking scripts..."

[ -f "scripts/gvhmr_to_robot.py" ] && check_pass "gvhmr_to_robot.py present" || check_fail "gvhmr_to_robot.py missing"
[ -f "scripts/vis_robot_motion.py" ] && check_pass "vis_robot_motion.py present" || check_fail "vis_robot_motion.py missing"
[ -f "setup.py" ] && check_pass "setup.py present" || check_fail "setup.py missing"

# 7. Check body models
echo ""
echo "7. Checking body models..."

smplx_neutral="GVHMR/inputs/checkpoints/body_models/smplx/SMPLX_NEUTRAL.npz"
smpl_neutral="GVHMR/inputs/checkpoints/body_models/smpl/SMPL_NEUTRAL.pkl"

if [ -f "$smplx_neutral" ]; then
    check_pass "SMPLX models present"
else
    check_fail "SMPLX models missing"
    echo "      Download from: https://smpl-x.is.tue.mpg.de/"
    echo "      Place in: GVHMR/inputs/checkpoints/body_models/smplx/"
fi

if [ -f "$smpl_neutral" ]; then
    check_pass "SMPL models present"
else
    check_fail "SMPL models missing"
    echo "      Download from: https://smpl.is.tue.mpg.de/"
    echo "      Place in: GVHMR/inputs/checkpoints/body_models/smpl/"
fi

# 8. Check GVHMR checkpoints
echo ""
echo "8. Checking GVHMR pretrained models..."

[ -f "GVHMR/inputs/checkpoints/gvhmr/gvhmr_siga24_release.ckpt" ] && check_pass "GVHMR checkpoint present" || check_fail "GVHMR checkpoint missing"
[ -f "GVHMR/inputs/checkpoints/hmr2/epoch=10-step=25000.ckpt" ] && check_pass "HMR2 checkpoint present" || check_fail "HMR2 checkpoint missing"
[ -f "GVHMR/inputs/checkpoints/vitpose/vitpose-h-multi-coco.pth" ] && check_pass "VitPose checkpoint present" || check_fail "VitPose checkpoint missing"
[ -f "GVHMR/inputs/checkpoints/yolo/yolov8x.pt" ] && check_pass "YOLO checkpoint present" || check_fail "YOLO checkpoint missing"

if [ ! -f "GVHMR/inputs/checkpoints/gvhmr/gvhmr_siga24_release.ckpt" ]; then
    echo "      Download from: https://drive.google.com/drive/folders/1eebJ13FUEXrKBawHpJroW0sNSxLjh9xD"
    echo "      Place in: GVHMR/inputs/checkpoints/{gvhmr,hmr2,vitpose,yolo}/"
fi

# 9. Check robot model
echo ""
echo "9. Checking robot model files..."

[ -f "assets/booster_t1/T1_locomotion.xml" ] && check_pass "Booster T1 XML model present" || check_fail "Booster T1 XML model missing"
[ -f "assets/booster_t1/T1_locomotion.urdf" ] && check_pass "Booster T1 URDF model present" || check_fail "Booster T1 URDF model missing"
[ -d "assets/booster_t1/meshes" ] && check_pass "Booster T1 meshes folder present" || check_fail "Booster T1 meshes folder missing"

# Summary
echo ""
echo "==================================================================="
echo "  Summary"
echo "==================================================================="
echo -e "${GREEN}Passed: $pass_count${NC}"
echo -e "${RED}Failed: $fail_count${NC}"
echo ""

if [ $fail_count -eq 0 ]; then
    echo -e "${GREEN}✓ Installation verification complete! You're ready to go!${NC}"
    echo ""
    echo "Next steps:"
    echo "  1. Read GUIDE.md for usage instructions"
    echo "  2. Try the one-command pipeline:"
    echo "     ./run_pipeline.sh --video /path/to/video.mp4"
    exit 0
else
    echo -e "${RED}✗ Some checks failed. Please review the output above.${NC}"
    echo ""
    echo "For detailed installation instructions, see GUIDE.md"
    exit 1
fi

