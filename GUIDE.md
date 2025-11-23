# Techunited Data Generation - Complete Guide

**Video to Robot Motion Pipeline for Booster T1**

> **Status:** ✅ Tested and Working | **Environment:** `gmr` | **Robot:** Booster T1

---

## Quick Overview

This package extracts human motion from videos and retargets it to the Booster T1 robot.

**Pipeline:** Video (.mp4) → GVHMR (human pose) → GMR (robot motion) → MuJoCo visualization + .pkl data

**What's Included:**
- ✅ GVHMR (complete source code)
- ✅ GMR (motion retargeting library)
- ✅ Booster T1 robot models
- ✅ All necessary scripts

**What to Download:**
- SMPLX/SMPL body models (~300 MB) - requires signup
- GVHMR checkpoints (~10 GB) - from Google Drive

---

## Part 1: Installation

### Prerequisites

- Ubuntu 20.04/22.04
- CUDA 12.1+ (for GPU acceleration)
- Anaconda or Miniconda
- Git

### Step 1: Clone Repository

```bash
git clone <YOUR_REPO_URL>/Techunited-DataGeneration
cd Techunited-DataGeneration
```

**Note:** GVHMR is already included in this repository!

### Step 2: Create Environment & Install

Run the automated setup script:

```bash
./setup_environment.sh
```

This will:
- Create conda environment named `gmr`
- Install GVHMR dependencies
- Install GMR dependencies
- Create necessary directories

**Or manual installation:**

```bash
# Create environment
conda create -y -n gmr python=3.10
conda activate gmr

# Install GVHMR
cd GVHMR
pip install -r requirements.txt
pip install -e .

# Install GMR
cd ..
pip install -e .
conda install -c conda-forge libstdcxx-ng -y
```

### Step 3: Reinstall GMR (Important!)

After setup, reinstall GMR to ensure all fixes are applied:

```bash
conda activate gmr
pip uninstall general-motion-retargeting -y
pip install -e .
```

This ensures the package uses the updated code with all SMPLX dimension fixes.

### Step 4: Download All Models & Checkpoints

Download everything you need (~10.5GB total) with one command:

```bash
./download_checkpoints.sh
```

The script will automatically download:
- ✅ SMPL/SMPL-X body models (~500MB)
- ✅ GVHMR checkpoints (~10GB)
- ✅ Detection models (YOLO, VitPose, HMR2)

The script will:
- Install `gdown` if needed
- Download all files from Google Drive
- Organize files into correct directories
- Show download status for each file
- Provide manual instructions if any downloads fail

**Final checkpoint structure:**
```
GVHMR/inputs/checkpoints/
├── body_models/
│   ├── smplx/
│   │   ├── SMPLX_NEUTRAL.npz
│   │   ├── SMPLX_MALE.npz
│   │   └── SMPLX_FEMALE.npz
│   └── smpl/
│       ├── SMPL_NEUTRAL.pkl
│       ├── SMPL_MALE.pkl
│       └── SMPL_FEMALE.pkl
├── gvhmr/gvhmr_siga24_release.ckpt
├── hmr2/epoch=10-step=25000.ckpt
├── vitpose/vitpose-h-multi-coco.pth
└── yolo/yolov8x.pt
```

### Step 5: Verify Installation

```bash
./verify_installation.sh
```

This checks:
- Conda environment exists
- Python packages installed
- CUDA available (optional)
- Body models present
- GVHMR checkpoints present

---

## Part 2: Usage Tutorial

### 🚀 One-Command Pipeline (Recommended)

The easiest way to process a video:

```bash
./run_pipeline.sh --video /path/to/your/video.mp4
```

This script automatically:
1. ✅ Runs GVHMR to extract human motion
2. ✅ Retargets motion to Booster T1
3. ✅ Saves robot motion data (.pkl)
4. ✅ Generates visualization video

**Usage:**
```bash
./run_pipeline.sh --video <path> [options]

Required:
  --video PATH          Path to input video file

Options:
  --robot NAME          Robot to use (default: booster_t1)
  --output-dir DIR      Where to save outputs (default: outputs)
  --no-skip-vo          Use visual odometry (for moving camera)
  --no-video            Skip video generation
  --help                Show help
```

**Examples:**
```bash
# Basic usage (most common)
./run_pipeline.sh --video inputs/my_video.mp4

# Custom output location
./run_pipeline.sh --video inputs/dance.mp4 --output-dir my_results

# For moving camera videos
./run_pipeline.sh --video inputs/dynamic.mp4 --no-skip-vo

# Different robot
./run_pipeline.sh --video inputs/motion.mp4 --robot unitree_g1
```

---

### Manual Step-by-Step Workflow

**Step 1: Activate Environment**
```bash
conda activate gmr
cd /path/to/Techunited-DataGeneration
```

**Step 2: Prepare Your Video**
- Place video in `data/` folder
- Supported formats: .mp4, .avi
- Requirements: Clear view of person, 5-30 seconds recommended

Example:
```bash
cp /path/to/your/video.mp4 data/
```

**Step 3: Extract Human Motion (GVHMR)**
```bash
cd GVHMR
python tools/demo/demo.py --video=../data/video.mp4 -s
cd ..
```

**Output:** `GVHMR/outputs/demo/video/hmr4d_results.pt`

**Step 4: Retarget to Booster T1 (GMR)**
```bash
python scripts/gvhmr_to_robot.py \
    --gvhmr_pred_file GVHMR/outputs/demo/video/hmr4d_results.pt \
    --robot booster_t1 \
    --rate_limit \
    --record_video \
    --save_path data/video_t1.pkl
```

**Outputs:**
- `data/video_t1.pkl` - Robot motion data
- `videos/booster_t1_hmr4d_results.mp4` - Visualization video

**Step 5: Replay Motion (Optional)**
```bash
python scripts/vis_robot_motion.py \
    --robot booster_t1 \
    --robot_motion_path data/video_t1.pkl \
    --rate_limit
```

### Command Options

**gvhmr_to_robot.py:**
- `--gvhmr_pred_file` - Path to hmr4d_results.pt (required)
- `--robot` - Robot type: `booster_t1` or `booster_t1_29dof`
- `--rate_limit` - Match 30 FPS playback speed
- `--record_video` - Record MuJoCo visualization
- `--save_path` - Save motion data (.pkl file)
- `--loop` - Loop motion continuously

**vis_robot_motion.py:**
- `--robot` - Robot type (required)
- `--robot_motion_path` - Path to .pkl file (required)
- `--rate_limit` - Match playback speed
- `--record_video` - Record video
- `--video_path` - Output video path

### Example: Complete Run

```bash
# Activate
conda activate gmr
cd Techunited-DataGeneration

# Process video
cd GVHMR
python tools/demo/demo.py --video=../data/soccer_move.mp4 -s
cd ..

# Retarget
python scripts/gvhmr_to_robot.py \
    --gvhmr_pred_file GVHMR/outputs/demo/soccer_move/hmr4d_results.pt \
    --robot booster_t1 \
    --rate_limit \
    --record_video \
    --save_path data/soccer_move_t1.pkl

# Output in: videos/booster_t1_hmr4d_results.mp4
```

---

## Part 3: Troubleshooting

### Common Issues

**Issue: "huggingface-hub version conflict"**

```bash
conda activate gmr
./fix_dependencies.sh
```

Or manually:
```bash
pip uninstall transformers huggingface-hub -y
pip install "huggingface-hub>=0.34.0,<1.0"
pip install "transformers>=4.30.0,<4.50.0"
```

**Issue: "SMPLX model files not found"**

Check files exist:
```bash
ls GVHMR/inputs/checkpoints/body_models/smplx/
ls assets/body_models/smplx/
```

If missing, download and copy:
```bash
cp GVHMR/inputs/checkpoints/body_models/smplx/*.npz assets/body_models/smplx/
```

**Issue: "CUDA out of memory"**

Solutions:
- Use shorter video clips (5-10 seconds)
- Reduce video resolution
- Use machine with more VRAM (8GB+ recommended)

**Issue: "No module named X"**

Reinstall packages:
```bash
conda activate gmr
cd GVHMR && pip install -e . && cd ..
pip install -e .
```

**Issue: "Rendering blank window"**

```bash
conda activate gmr
conda install -c conda-forge libstdcxx-ng -y
```

---

## Part 4: Advanced Usage

### Batch Processing Multiple Videos

```bash
for video in data/*.mp4; do
    filename=$(basename "$video" .mp4)
    echo "Processing: $filename"
    
    # Extract motion
    cd GVHMR
    python tools/demo/demo.py --video=../data/$filename.mp4 -s
    cd ..
    
    # Retarget
    python scripts/gvhmr_to_robot.py \
        --gvhmr_pred_file GVHMR/outputs/demo/$filename/hmr4d_results.pt \
        --robot booster_t1 \
        --save_path data/${filename}_t1.pkl
    
    echo "Completed: $filename"
done
```

### Mirror Video (Left-Right Flip)

```bash
python scripts/mirror_video.py \
    --input data/original.mp4 \
    --output data/original_mirrored.mp4
```

### Use 29 DoF Variant

```bash
python scripts/gvhmr_to_robot.py \
    --gvhmr_pred_file GVHMR/outputs/demo/video/hmr4d_results.pt \
    --robot booster_t1_29dof \
    --rate_limit \
    --save_path data/video_t1_29dof.pkl
```

### Fast Processing (No Visualization)

```bash
python scripts/gvhmr_to_robot.py \
    --gvhmr_pred_file GVHMR/outputs/demo/video/hmr4d_results.pt \
    --robot booster_t1 \
    --save_path data/video_t1.pkl
# No --rate_limit, no --record_video = fastest
```

---

## Part 5: Output Format

### Motion Data (.pkl files)

Each pickle file contains:
```python
{
    "fps": 30,                           # Frame rate
    "root_pos": ndarray (N, 3),         # Base position trajectory
    "root_rot": ndarray (N, 4),         # Base rotation (xyzw quaternion)
    "dof_pos": ndarray (N, num_dofs),  # Joint positions
    "local_body_pos": None,             # Reserved
    "link_body_list": None              # Reserved
}
```

### Loading Motion Data

```python
import pickle
import numpy as np

with open('data/motion.pkl', 'rb') as f:
    data = pickle.load(f)
    
print(f"FPS: {data['fps']}")
print(f"Frames: {len(data['root_pos'])}")
print(f"DoF: {data['dof_pos'].shape[1]}")

# Access data
root_positions = data['root_pos']  # (N, 3)
root_rotations = data['root_rot']  # (N, 4) xyzw
joint_angles = data['dof_pos']     # (N, dof)
```

---

## Part 6: Package Structure

```
Techunited-DataGeneration/
├── README.md                    # Package overview
├── GUIDE.md                     # This file
├── setup_environment.sh         # Automated setup
├── verify_installation.sh       # Check installation
├── fix_dependencies.sh          # Fix conflicts
├── .gitignore                   # Git ignore rules
│
├── scripts/
│   ├── gvhmr_to_robot.py       # Main retargeting script
│   ├── vis_robot_motion.py     # Motion replay
│   └── mirror_video.py         # Video utility
│
├── general_motion_retargeting/ # GMR library
│   ├── motion_retarget.py      # Retargeting engine
│   ├── robot_motion_viewer.py  # MuJoCo viewer
│   ├── utils/smpl.py           # SMPLX integration (with fixes)
│   └── ik_configs/             # Robot configurations
│       ├── smplx_to_t1.json    # Booster T1 23 DoF
│       └── smplx_to_t1_29dof.json # Booster T1 29 DoF
│
├── third_party/                # Dependencies
│
├── assets/
│   └── booster_t1/             # Robot models
│       ├── T1_locomotion.xml   # MuJoCo model
│       ├── T1_locomotion.urdf  # URDF model
│       └── meshes/             # 44 STL files
│
├── GVHMR/                      # GVHMR repository
│   ├── tools/demo/             # Demo scripts
│   ├── hmr4d/                  # Model code
│   ├── inputs/checkpoints/     # Download models here
│   └── outputs/demo/           # Results output
│
├── data/                       # Your videos & motion data
└── videos/                     # Recorded visualizations
```

---

## Part 7: Technical Details

### Pre-Fixed Integration Issues

This package includes fixes for:
- ✅ SMPLX betas dimension mismatch
- ✅ Missing expression parameters
- ✅ Betas size configuration (16 dimensions)
- ✅ SMPLX model explicit configuration
- ✅ Dependency version conflicts

These fixes are in: `general_motion_retargeting/utils/smpl.py`

### Dependency Versions

Working versions:
- `huggingface-hub==0.36.0`
- `transformers==4.49.0`
- `torch>=2.0.0` with CUDA
- `smplx` (latest)
- `mujoco` (latest)

### Performance

- **GVHMR:** 1-5 FPS (GPU dependent)
- **GMR Retargeting:** 35-70 FPS (real-time capable)
- **Recommended:** 8GB+ VRAM for GVHMR

---

## Part 8: Quick Reference

### Daily Workflow

```bash
# 1. Activate
conda activate gmr
cd Techunited-DataGeneration

# 2. Extract
cd GVHMR
python tools/demo/demo.py --video=../data/YOUR_VIDEO.mp4 -s
cd ..

# 3. Retarget
python scripts/gvhmr_to_robot.py \
    --gvhmr_pred_file GVHMR/outputs/demo/YOUR_VIDEO/hmr4d_results.pt \
    --robot booster_t1 \
    --rate_limit \
    --record_video \
    --save_path data/YOUR_VIDEO_t1.pkl
```

### Maintenance

**Check installation:**
```bash
./verify_installation.sh
```

**Fix dependencies:**
```bash
./fix_dependencies.sh
```

**Clean reinstall:**
```bash
conda env remove -n gmr -y
./setup_environment.sh
# Re-download models
```

---

## Support & Credits

**Integrates:**
- GMR: https://github.com/YanjieZe/GMR (MIT License)
- GVHMR: https://github.com/zju3dv/GVHMR
- MuJoCo: https://mujoco.org/
- Booster T1: https://www.boosterobotics.com/

**Package Version:** 1.0  
**Status:** ✅ Tested & Working  
**Last Updated:** November 2025

---

## Summary

**Setup:** Clone → Run setup script → Download models → Verify  
**Usage:** Place video → Run GVHMR → Run GMR → Get motion data  
**Output:** .pkl motion data + .mp4 visualization

**This package is production-ready for Booster T1 motion generation from videos!** 🚀

