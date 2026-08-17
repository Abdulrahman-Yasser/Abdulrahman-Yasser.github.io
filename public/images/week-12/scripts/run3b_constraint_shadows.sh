#!/bin/bash
# One throwaway script per experiment run. Hardcoded on purpose.
set -e
W=1640; H=1232
MODE="1640:1232"        # pin binned full-FOV mode (NOT width/height alone -> avoids crop)
DUR=45000              # ms of video per run
SETTLE=2000            # ms AE/AWB settle before still
SESSION="captures/run3b_shadows_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$SESSION"
ln -sfn "$(basename "$SESSION")" captures/latest   # always points at newest run
echo "[run3b] AE auto, constraint = shadows (both)"
OPT="--awb auto --metering centre --exposure long"   # long biases toward lifting shadows

rpicam-still --camera 0 --mode $MODE --width $W --height $H -t $SETTLE --nopreview $OPT -o "$SESSION/camA.png" &
rpicam-still --camera 1 --mode $MODE --width $W --height $H -t $SETTLE --nopreview $OPT -o "$SESSION/camB.png" &
wait
rpicam-vid --camera 0 --mode $MODE --width $W --height $H --codec mjpeg -t $DUR --nopreview $OPT \
  --metadata "$SESSION/camA_meta.json" --metadata-format json -o "$SESSION/camA.mjpeg" &
rpicam-vid --camera 1 --mode $MODE --width $W --height $H --codec mjpeg -t $DUR --nopreview $OPT \
  --metadata "$SESSION/camB_meta.json" --metadata-format json -o "$SESSION/camB.mjpeg" &
wait
echo "-> $SESSION"
