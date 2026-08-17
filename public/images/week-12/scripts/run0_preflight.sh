#!/bin/bash
# Parked sanity check. Run FIRST, every session. No driving.
set -e
W=1640; H=1232; MODE="1640:1232"
SESSION="captures/run0_preflight_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$SESSION"
ln -sfn "$(basename "$SESSION")" captures/latest   # always points at newest run
echo "[preflight] checking both cameras..."

# list cameras
rpicam-hello --list-cameras || { echo "!! camera enumeration failed"; exit 1; }

# grab one still from each + a short metadata sample
for CAM in 0 1; do
  echo "  camera $CAM: still + 3s metadata sample"
  rpicam-still --camera $CAM --mode $MODE --width $W --height $H -t 1500 --nopreview \
    -o "$SESSION/cam${CAM}_still.png"
  rpicam-vid --camera $CAM --mode $MODE --width $W --height $H --codec mjpeg -t 3000 --nopreview \
    --metadata "$SESSION/cam${CAM}_meta.json" --metadata-format json -o "$SESSION/cam${CAM}_test.mjpeg"
done

echo ""
echo "NOW CHECK:"
echo "  - both cam0_still.png and cam1_still.png exist and show the board + sheets"
echo "  - open cam0_meta.json : is it non-empty with per-frame numbers?"
echo "  - if meta.json is empty/errored -> your rpicam is too old, tell Claude"
echo "-> $SESSION"
ls -la "$SESSION"
