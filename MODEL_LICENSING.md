# ⚠️ IMPORTANT: Model Licensing Information

## SMPL and SMPL-X Body Models

### ❌ **CANNOT be uploaded to GitHub**

The SMPL and SMPL-X body models have **restrictive licenses** that prohibit redistribution:

- **SMPL License:** Requires registration and agreement to terms of use
- **SMPL-X License:** Requires registration and agreement to terms of use
- **Redistribution:** Explicitly prohibited without permission
- **Commercial Use:** Restricted (check license terms)

### 📋 License Requirements

From the official websites:
- Users must register with their academic/work email
- Users must agree to the terms of use
- Users must download directly from official sources
- **Redistribution is NOT allowed**

### ✅ What You CAN Do

1. **Provide download instructions** (we do this in GUIDE.md)
2. **Provide scripts to verify models** (verify_installation.sh)
3. **Document the file structure** required
4. **Link to official download pages**

### ❌ What You CANNOT Do

1. ❌ Upload SMPL/SMPL-X `.npz` or `.pkl` files to GitHub
2. ❌ Include them in releases
3. ❌ Host them on your own servers
4. ❌ Share them via Google Drive/Dropbox
5. ❌ Redistribute in any form without explicit permission

## GVHMR Checkpoints

The GVHMR model checkpoints have more permissive licenses:

### ✅ Can be automated (Google Drive download)

We can provide scripts to download:
- `gvhmr_siga24_release.ckpt`
- `epoch=10-step=25000.ckpt` (HMR2)
- `vitpose-h-multi-coco.pth`
- `yolov8x.pt`

These are hosted by the GVHMR team on Google Drive and can be downloaded via scripts.

### ⚠️ Check GVHMR License

While GVHMR provides these for download, check their repository for:
- License terms
- Commercial use restrictions
- Attribution requirements

## Robot Models

The Booster T1 robot models:
- Check with Booster Robotics for license terms
- May have commercial use restrictions
- Include appropriate attribution

## Recommendation

### For Your Repository:

```
✅ Include:
- Setup scripts
- Documentation
- Installation guides
- Download automation for GVHMR checkpoints

❌ Do NOT Include:
- SMPL/SMPL-X model files
- Any copyrighted robot models without permission
```

### For Users:

**Required Manual Steps:**
1. Register and download SMPL/SMPL-X from official websites
2. Place files in `GVHMR/inputs/checkpoints/body_models/`
3. Run verification script

**Can Be Automated:**
- GVHMR checkpoints (if we add download script)
- Conda environment setup
- Package installation

## Alternative: Create Setup Script with gdown

We can create a script that:
1. ✅ Downloads GVHMR checkpoints automatically (from their official Google Drive)
2. ❌ Reminds users to download SMPL/SMPL-X manually
3. ✅ Checks if models are present
4. ✅ Verifies installation

This way users only need to:
1. Download SMPL/SMPL-X manually (2 files each, 6 total)
2. Run `./setup_environment.sh` (does everything else)
3. Run `./verify_installation.sh`
4. Run `./run_pipeline.sh --video ...`

---

## Summary

| Component | Can Upload to GitHub? | Can Auto-Download? |
|-----------|----------------------|-------------------|
| SMPL/SMPL-X Models | ❌ NO | ❌ NO - Requires registration |
| GVHMR Checkpoints | ⚠️ Maybe (check license) | ✅ YES - From their Google Drive |
| Robot Models | ⚠️ Check with manufacturer | ❌ NO |
| Setup Scripts | ✅ YES | N/A |
| Documentation | ✅ YES | N/A |
| GMR Code | ✅ YES (MIT License) | N/A |

**Bottom Line:** You MUST require users to download SMPL/SMPL-X manually. Everything else can potentially be automated.

---

**Important:** Always review and comply with license terms. When in doubt, require manual download with proper attribution.

