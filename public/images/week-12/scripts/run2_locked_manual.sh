#!/bin/bash
# One throwaway script per experiment run. Hardcoded on purpose.
set -e
W=1640; H=1232
MODE="1640:1232"        # pin binned full-FOV mode (NOT width/height alone -> avoids crop)
DUR=45000              # ms of video per run
SETTLE=2000            # ms AE/AWB settle before still

# >>> EDIT THESE with the values you read off run1's daylight metadata <<<
SHUTTER=8000          # microseconds (ExposureTime)
GAIN=1.5              # AnalogueGain
AWBGAINS="1.4,1.9"    # ColourGains  r,b
# <<< ------------------------------------------------------------- >>>

SESSION="captures/run2_locked_manual_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$SESSION"
ln -sfn "$(basename "$SESSION")" captures/latest   # always points at newest run
echo "[run2] both cameras LOCKED: shutter=$SHUTTER gain=$GAIN awbgains=$AWBGAINS"

LOCK="--shutter $SHUTTER --gain $GAIN --awbgains $AWBGAINS --denoise off"

rpicam-still --camera 0 --mode $MODE --width $W --height $H -t $SETTLE --nopreview $LOCK -o "$SESSION/camA.png" &
rpicam-still --camera 1 --mode $MODE --width $W --height $H -t $SETTLE --nopreview $LOCK -o "$SESSION/camB.png" &
wait

rpicam-vid --camera 0 --mode $MODE --width $W --height $H --codec mjpeg -t $DUR --nopreview $LOCK \
  --metadata "$SESSION/camA_meta.json" --metadata-format json -o "$SESSION/camA.mjpeg" &
rpicam-vid --camera 1 --mode $MODE --width $W --height $H --codec mjpeg -t $DUR --nopreview $LOCK \
  --metadata "$SESSION/camB_meta.json" --metadata-format json -o "$SESSION/camB.mjpeg" &
wait
echo "-> $SESSION"
