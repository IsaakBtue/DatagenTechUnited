#!/bin/bash
# Techunited Data Generation Pipeline
# Processes video -> GVHMR -> GMR retargeting to Booster T1

set -e  # Exit on error

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored messages
print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Parse arguments
VIDEO_PATH=""
ROBOT="booster_t1"
OUTPUT_DIR="outputs"
SKIP_VO=true
RECORD_VIDEO=true

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --video)
            VIDEO_PATH="$2"
            shift 2
            ;;
        --robot)
            ROBOT="$2"
            shift 2
            ;;
        --output-dir)
            OUTPUT_DIR="$2"
            shift 2
            ;;
        --no-skip-vo)
            SKIP_VO=false
            shift
            ;;
        --no-video)
            RECORD_VIDEO=false
            shift
            ;;
        -h|--help)
            echo "Usage: $0 --video <path_to_video> [options]"
            echo ""
            echo "Required:"
            echo "  --video PATH          Path to input video file"
            echo ""
            echo "Options:"
            echo "  --robot NAME          Robot to retarget to (default: booster_t1)"
            echo "  --output-dir DIR      Output directory (default: outputs)"
            echo "  --no-skip-vo          Don't skip visual odometry (use for moving camera)"
            echo "  --no-video            Don't record output video"
            echo "  -h, --help            Show this help message"
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# Validate inputs
if [ -z "$VIDEO_PATH" ]; then
    print_error "Video path is required. Use --video <path>"
    echo "Use --help for usage information"
    exit 1
fi

if [ ! -f "$VIDEO_PATH" ]; then
    print_error "Video file not found: $VIDEO_PATH"
    exit 1
fi

# Get absolute path
VIDEO_PATH=$(realpath "$VIDEO_PATH")
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Extract video name (without extension)
VIDEO_BASENAME=$(basename "$VIDEO_PATH")
VIDEO_NAME="${VIDEO_BASENAME%.*}"

print_info "===================================================="
print_info "Techunited Data Generation Pipeline"
print_info "===================================================="
print_info "Video: $VIDEO_PATH"
print_info "Video Name: $VIDEO_NAME"
print_info "Robot: $ROBOT"
print_info "Output Directory: $OUTPUT_DIR"
print_info "Skip Visual Odometry: $SKIP_VO"
print_info "Record Video: $RECORD_VIDEO"
print_info "===================================================="

# Auto-activate conda environment
if [[ "$CONDA_DEFAULT_ENV" != "HumanoidDataGeneration" ]]; then
    print_info "Activating 'HumanoidDataGeneration' conda environment..."
    
    # Initialize conda for bash shell
    if [ -f "$HOME/miniforge3/etc/profile.d/conda.sh" ]; then
        source "$HOME/miniforge3/etc/profile.d/conda.sh"
    elif [ -f "$HOME/anaconda3/etc/profile.d/conda.sh" ]; then
        source "$HOME/anaconda3/etc/profile.d/conda.sh"
    elif [ -f "$HOME/miniconda3/etc/profile.d/conda.sh" ]; then
        source "$HOME/miniconda3/etc/profile.d/conda.sh"
    else
        # Try to find conda
        CONDA_BASE=$(conda info --base 2>/dev/null)
        if [ -n "$CONDA_BASE" ]; then
            source "$CONDA_BASE/etc/profile.d/conda.sh"
        else
            print_error "Could not find conda installation"
            print_error "Please activate manually: conda activate HumanoidDataGeneration"
            exit 1
        fi
    fi
    
    conda activate HumanoidDataGeneration
    
    if [[ "$CONDA_DEFAULT_ENV" != "HumanoidDataGeneration" ]]; then
        print_error "Failed to activate 'HumanoidDataGeneration' environment"
        print_error "Please run: conda activate HumanoidDataGeneration"
        exit 1
    fi
    
    print_info "✓ Environment activated"
fi

# Step 1: Run GVHMR
print_info "Step 1/3: Running GVHMR to extract human motion..."
cd "$SCRIPT_DIR/GVHMR"

GVHMR_CMD="python tools/demo/demo.py --video=$VIDEO_PATH"
if [ "$SKIP_VO" = true ]; then
    GVHMR_CMD="$GVHMR_CMD -s"
fi

print_info "Running: $GVHMR_CMD"
$GVHMR_CMD

# Find the generated output (use absolute path)
GVHMR_OUTPUT_DIR="$SCRIPT_DIR/GVHMR/outputs/demo/$VIDEO_NAME"
HMR4D_FILE="$GVHMR_OUTPUT_DIR/hmr4d_results.pt"

if [ ! -f "$HMR4D_FILE" ]; then
    print_error "GVHMR output not found: $HMR4D_FILE"
    print_error "Expected location: $HMR4D_FILE"
    exit 1
fi

print_info "✓ GVHMR processing complete"
print_info "  Output: $HMR4D_FILE"

# Step 2: Run GMR retargeting
print_info "Step 2/3: Retargeting to $ROBOT..."
cd "$SCRIPT_DIR"

# Create output directory for final results (use absolute path)
mkdir -p "$SCRIPT_DIR/$OUTPUT_DIR"
OUTPUT_PKL="$SCRIPT_DIR/$OUTPUT_DIR/${VIDEO_NAME}_${ROBOT}.pkl"

GMR_CMD="python scripts/gvhmr_to_robot.py \
    --gvhmr_pred_file $HMR4D_FILE \
    --robot $ROBOT \
    --rate_limit \
    --save_path $OUTPUT_PKL"

if [ "$RECORD_VIDEO" = true ]; then
    GMR_CMD="$GMR_CMD --record_video"
fi

print_info "Running GMR retargeting..."
$GMR_CMD

print_info "✓ Retargeting complete"
print_info "  Robot motion saved: $OUTPUT_PKL"

# Step 3: Summary
print_info "===================================================="
print_info "Pipeline Complete! 🎉"
print_info "===================================================="
print_info "Outputs:"
print_info "  1. GVHMR results: $GVHMR_OUTPUT_DIR/"
print_info "  2. Robot motion: $OUTPUT_PKL"
if [ "$RECORD_VIDEO" = true ]; then
    # Check both possible video locations
    VIDEO_NAME_MP4="$SCRIPT_DIR/videos/${ROBOT}_hmr4d_results.mp4"
    OUTPUT_MP4="${OUTPUT_PKL%.pkl}.mp4"
    if [ -f "$VIDEO_NAME_MP4" ]; then
        print_info "  3. Video: $VIDEO_NAME_MP4"
    elif [ -f "$OUTPUT_MP4" ]; then
        print_info "  3. Video: $OUTPUT_MP4"
    fi
fi
print_info "===================================================="
print_info ""
print_info "To visualize the robot motion again:"
print_info "  python scripts/vis_robot_motion.py --motion_file $OUTPUT_PKL --robot $ROBOT"

