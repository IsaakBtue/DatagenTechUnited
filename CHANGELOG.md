# Changelog

## November 23, 2025 - v2.0 (Latest)

### 🚀 Major Changes

#### Complete Automation
- **Fully automated downloads:** `download_checkpoints.sh` now downloads ALL models
- Downloads SMPL/SMPL-X body models automatically from Google Drive
- Downloads sample video (intercept1.mp4) for immediate testing
- No more manual model registration or downloads!

#### Single Documentation File
- **Consolidated docs:** All documentation now in single README.md
- Removed GUIDE.md - everything in one place
- Clear 4-step workflow: setup → download → verify → run
- Simpler, cleaner, easier to follow

#### Enhanced Download Script
- Improved file organization - properly handles Google Drive folder structure
- Downloads to temp directory first, then organizes files
- Better handling of nested folders from gdown
- Automatic sample video placement in `data/` folder
- Enhanced verification with file size display

### 📚 Documentation
- Complete rewrite of README.md - comprehensive single-file guide
- Removed GUIDE.md (consolidated into README.md)
- Added detailed troubleshooting section
- Clearer project structure visualization
- Better examples and use cases

### ✅ Workflow
1. `./setup_environment.sh` - Setup environment
2. `./download_checkpoints.sh` - Download everything (~10.5GB)
3. `./verify_installation.sh` - Verify setup
4. `./run_pipeline.sh --video data/intercept1.mp4` - Process sample video

---

## November 23, 2025 - v1.1.1

### 🐛 Bug Fixes

- Fixed path resolution in `run_pipeline.sh` - now uses absolute paths
- Fixed SMPLX dimension errors by ensuring proper package installation
- Added package reinstallation step to setup process
- Fixed video output path reporting in pipeline completion message

### 📚 Documentation

- Added `INSTALL_NOTES.md` - important notes about editable installation
- Updated GUIDE.md with reinstallation step after body model download
- Added troubleshooting for "wrong module being imported" issues

### ✅ Tested & Verified

- Full pipeline tested with intercept1.mp4 sample
- Confirmed GVHMR → GMR → MuJoCo visualization works end-to-end
- Generated outputs: `.pkl` motion data + `.mp4` visualization video

---

## November 23, 2025 - v1.1

### ✨ New Features

#### One-Command Pipeline Script
- Added `run_pipeline.sh` - process videos with a single command
- Automatically runs GVHMR → GMR → saves outputs
- Supports custom options (robot type, output directory, camera settings)
- Colored output for better user experience

Example:
```bash
./run_pipeline.sh --video /path/to/video.mp4
```

#### Unified Body Model Location
- **Simplified setup:** SMPLX models now in ONE location only
- All scripts use `GVHMR/inputs/checkpoints/body_models/`
- Removed requirement to copy files to `assets/body_models/smplx/`
- Updated `gvhmr_to_robot.py` to use unified location

### 🔧 Improvements

- Updated `setup_environment.sh` to reflect single body model location
- Updated `verify_installation.sh` to check only GVHMR checkpoint location
- Consolidated all documentation into single `GUIDE.md`
- Updated README.md with one-command pipeline instructions
- Improved GUIDE.md with clearer step-by-step instructions

### 📚 Documentation

- Added pipeline script usage examples
- Clarified body model installation (no more duplicates!)
- Updated all references to body model paths
- Added this CHANGELOG.md

---

## Previous Version - v1.0

### Initial Features
- GVHMR integration for human motion extraction
- GMR retargeting to Booster T1 robot
- MuJoCo visualization
- Automated environment setup
- Fixed SMPLX tensor dimension issues
- Dependency conflict resolution (`fix_dependencies.sh`)
- Comprehensive documentation

### Known Limitations (v1.0)
- Required copying SMPLX files to two locations (fixed in v1.1)
- Manual two-step process (GVHMR → GMR) (fixed in v1.1)
- Multiple documentation files (consolidated in v1.1)

---

## Migration Guide (v1.0 → v1.1)

If you're upgrading from v1.0:

1. **Body Models:** You can now delete `assets/body_models/smplx/` (optional)
   - All files are read from `GVHMR/inputs/checkpoints/body_models/`
   - No action needed if you keep the old location

2. **New Pipeline Script:** Start using `run_pipeline.sh` for easier workflow
   ```bash
   # Old way (still works):
   cd GVHMR && python tools/demo/demo.py --video=... && cd ..
   python scripts/gvhmr_to_robot.py --gvhmr_pred_file ...
   
   # New way (recommended):
   ./run_pipeline.sh --video /path/to/video.mp4
   ```

3. **Documentation:** All guides consolidated into `GUIDE.md`
   - Old files (INSTALLATION_GUIDE.md, QUICK_START.md, etc.) removed
   - Everything now in single comprehensive guide

---

**Current Version:** v1.1  
**Status:** ✅ Production Ready  
**Last Updated:** November 23, 2025

