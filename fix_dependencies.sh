#!/bin/bash
# Fix for huggingface-hub and transformers dependency conflict

echo "=================================================="
echo "  Fixing Dependency Conflicts"
echo "=================================================="
echo ""

# Activate gmr environment
eval "$(conda shell.bash hook)"
conda activate gmr

echo "Removing conflicting packages..."
pip uninstall transformers huggingface-hub -y

echo ""
echo "Installing compatible versions..."
pip install "huggingface-hub>=0.34.0,<1.0"
pip install "transformers>=4.30.0,<4.50.0"

echo ""
echo "=================================================="
echo "  ✓ Dependencies fixed!"
echo "=================================================="
echo ""
echo "Installed versions:"
python -c "import transformers, huggingface_hub; print(f'  ✓ transformers: {transformers.__version__}'); print(f'  ✓ huggingface_hub: {huggingface_hub.__version__}')"
echo ""
echo "You can now run:"
echo "  cd GVHMR"
echo "  python tools/demo/demo.py --video=../data/your_video.mp4 -s"
