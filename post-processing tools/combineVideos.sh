#!/usr/bin/env bash
#
# This little tool combine recorded pixelflut .mkv's into a big standardized 1080p h265 video mp4 as a timelapse.
# This is normally used to spread the recording on your favorite video sharing platform.
#
set -e

INPUT_FILES=( "$@" )
RESULT_FILE='combined.mp4'
OUTPUT_RESOLUTION='w=1920:h=1080'
TIME_MULTIPLIER=1/100 # 100x timelapse

if [ -z "$INPUT_FILES" ]; then
  echo 'No input files are detected.'
  echo 'Arguments like this are expected: ./combineVideos.sh PixelTest-2022-04-30_10-26.mkv PixelTest-2022-04-30_10-30.mkv'
  echo 'For a full folder of files use ./combineVideos.sh $(ls *.mkv | sort)'
  exit 1
fi

if grep -qi microsoft /proc/version; then
  echo "Detected WSL environment. Expecting ffmpeg.exe on PATH."
  FFMPEG='ffmpeg.exe'
else
  FFMPEG='ffmpeg'
fi

echo "Check encoders..."
AVAILABLE_ENCODERS=$(${FFMPEG} -hide_banner -encoders)
if echo "$AVAILABLE_ENCODERS" | grep -E "cuvid|nvenc|cuda"; then
  echo "Detected hardware supported encoders. Will use hevc_nvenc encoder."
  ENCODER='hevc_nvenc'
else
  echo "No hardware supported encoder available in ffmpeg. Will use the libx265 encoder."
  ENCODER='libx265'
fi

echo "Check files"
sleep 2

for file in "${INPUT_FILES[@]}"; do
  if [ -f "$file" ]; then
    echo "$file: exists"
  else
    echo "Could not find '$file'"
    exit 1
  fi
done

echo "Start creating video"
sleep 2

INPUTS=""
INPUT_VIDEO_STREAMS=""
INPUT_COUNT=0
for file in "${INPUT_FILES[@]}"; do
   INPUTS="$INPUTS -i $file"
   INPUT_VIDEO_SCALES="$INPUT_VIDEO_SCALES [${INPUT_COUNT}:v:0] scale=${OUTPUT_RESOLUTION} [scaled${INPUT_COUNT}];"
   INPUT_VIDEO_STREAMS="$INPUT_VIDEO_STREAMS [scaled${INPUT_COUNT}]"
   INPUT_COUNT=$((INPUT_COUNT+1))
done

set -x
$FFMPEG \
  $INPUTS \
  -filter_complex "$INPUT_VIDEO_SCALES $INPUT_VIDEO_STREAMS concat=n=${INPUT_COUNT}:v=1:a=0 [combinedv]; \
  [combinedv] setpts=(${TIME_MULTIPLIER})*PTS [timelapse]" \
  -map '[timelapse]' -c:v "${ENCODER}" -preset fast -pixel_format yuv444p -b:v 6M -an \
  -r 30 ${RESULT_FILE}
set +x

echo "Finished creation of $RESULT_FILE"
