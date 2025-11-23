# Techunited Data Generation

**Video to Robot Motion Pipeline for Booster T1**

[![Status](https://img.shields.io/badge/status-working-brightgreen)]() [![Tested](https://img.shields.io/badge/tested-Nov%202025-blue)]() [![Robot](https://img.shields.io/badge/robot-Booster%20T1-orange)]()

---

## What This Does

Extracts human motion from videos and retargets it to the Booster T1 humanoid robot.

**Pipeline:** Video → GVHMR (human pose) → GMR (robot motion) → MuJoCo visualization + motion data

---

## 🚀 Quick Start

### Step 1: Setup (One-Time)
```bash
git clone https://github.com/IsaakBtue/DatagenTechUnited.git
cd DatagenTechUnited
./setup_environment.sh
```

### Step 2: Download Models (One-Time)

Download all required models and checkpoints (~10.5GB):

```bash
./download_checkpoints.sh
```

This will automatically download:
- ✅ SMPL/SMPL-X body models (~500MB)
- ✅ GVHMR checkpoints (~10GB)
- ✅ All detection models (YOLO, VitPose, etc.)

The script will show you which files were successfully downloaded and provide instructions for any files that need manual download.

### Step 3: Verify (One-Time)
```bash
./verify_installation.sh
```

### Step 4: Process Videos (Anytime!)
```bash
./run_pipeline.sh --video /path/to/your/video.mp4
```

**That's it!** The pipeline automatically:
- ✅ Activates conda environment (no need to do it manually!)
- ✅ Extracts human motion with GVHMR
- ✅ Retargets to Booster T1
- ✅ Saves motion data (.pkl)
- ✅ Creates visualization video (.mp4)

### Pipeline Options
```bash
./run_pipeline.sh --video <path> [options]

Options:
  --robot NAME          Robot to use (default: booster_t1)
  --output-dir DIR      Output directory (default: outputs)
  --no-skip-vo          Use visual odometry (for moving camera)
  --no-video            Skip video generation
  --help                Show all options
```

### Examples
```bash
# Basic usage
./run_pipeline.sh --video /path/to/your/video.mp4

# Different robot
./run_pipeline.sh --video /path/to/video.mp4 --robot unitree_g1

# Moving camera (if camera is moving in video)
./run_pipeline.sh --video /path/to/dynamic.mp4 --no-skip-vo
```

---

## Documentation

📚 **[GUIDE.md](GUIDE.md)** - Complete setup and usage guide

📋 **[CHANGELOG.md](CHANGELOG.md)** - Version history and updates

**GUIDE.md includes:**
- Complete installation instructions
- Step-by-step workflow
- Model download guide
- Troubleshooting
- Advanced usage

---

## What's Included

✅ GVHMR (complete source code)  
✅ GMR (motion retargeting library with fixes)  
✅ Booster T1 robot models  
✅ All necessary scripts  
✅ Automated setup  

**What to download:** All models included in automated download script

---

## Requirements

- Ubuntu 20.04/22.04
- Python 3.10
- CUDA 12.1+ (GPU with 8GB+ VRAM recommended)
- Conda/Miniconda

---

## Package Structure

```
Techunited-DataGeneration/
├── README.md                    # This file
├── GUIDE.md                     # Complete guide
├── MODEL_LICENSING.md           # Licensing info
├── run_pipeline.sh              # Main script!
├── setup_environment.sh         # One-time setup
├── verify_installation.sh       # Check installation
├── general_motion_retargeting/  # GMR library (with fixes)
├── GVHMR/                       # GVHMR source code
├── assets/booster_t1/           # Robot models
├── scripts/                     # Utility scripts
├── data/                        # Place input videos here
├── outputs/                     # Motion data (.pkl)
└── videos/                      # Visualization videos (.mp4)
```

---

## Features

✅ **One-Command Pipeline** - Process videos with a single script  
✅ **Tested & Working** - Verified with real videos  
✅ **Pre-Fixed Issues** - SMPLX integration bugs resolved  
✅ **Unified Body Models** - Single location for all SMPLX files  
✅ **Automated Setup** - Environment creation & dependency management  
✅ **Complete Documentation** - Comprehensive guide included  
✅ **Booster T1 Optimized** - Specific configuration for T1 robot  
✅ **Real-time Capable** - 35-70 FPS retargeting speed  

---

## Output Format

Motion data saved as `.pkl` files:
- Frame rate (30 FPS)
- Base position trajectory
- Base rotation (quaternion)
- Joint angles

Plus `.mp4` visualization video from MuJoCo.

---

## Support

**Installation issues?** Run `./verify_installation.sh`  
**Dependency conflicts?** Run `./fix_dependencies.sh`  
**Need help?** Read `GUIDE.md`

---

## Credits

Integrates:
- **GMR** - https://github.com/YanjieZe/GMR (MIT License)
- **GVHMR** - https://github.com/zju3dv/GVHMR
- **MuJoCo** - https://mujoco.org/
- **Booster T1** - https://www.boosterobotics.com/

---

## License

- GMR: MIT License
- GVHMR: Check their repository
- Robot models: Check manufacturer

---

**Version:** 1.2  
**Status:** ✅ Production Ready  
**Last Updated:** November 2025

---

## Troubleshooting

**Installation issues?** Run `./verify_installation.sh` to check what's missing.

**Dependency conflicts?** Run `./fix_dependencies.sh` to fix version issues.

**Pipeline fails?** Make sure you downloaded all models (see Step 2 above).

**More help?** See [GUIDE.md](GUIDE.md) for detailed troubleshooting.

---

**Ready to start?** Follow the Quick Start steps above! 🚀
