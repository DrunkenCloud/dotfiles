#!/bin/bash
# Voice typing: SUPER+D starts listening, SUPER+D again stops, transcribes
# (whisper.cpp, offline, on the NVIDIA GPU) and types the text into the
# focused window. The text is also copied to the clipboard.
#
# DICTATE_TEST_WAV=file.wav DICTATE_DRYRUN=1 dictate.sh   -> transcribe a file, print instead of typing

MODEL="$HOME/.local/share/whisper/ggml-large-v3-turbo-q5_0.bin"
LANG_CODE="en"                     # set to "auto" to detect the language automatically
RUN="${XDG_RUNTIME_DIR:?XDG_RUNTIME_DIR not set}"
WAV="$RUN/dictate.wav"
PIDF="$RUN/dictate.pid"
STATE="$RUN/dictate.state"         # read by the waybar indicator: rec | busy | (absent)

bar() { if [ -n "$1" ]; then echo "$1" > "$STATE"; else rm -f "$STATE"; fi; pkill -RTMIN+9 waybar; }

transcribe() {
    bar busy
    # GGML_VK_VISIBLE_DEVICES=1 -> the RTX 3050 (device 0 is the Intel iGPU, ~4x slower)
    GGML_VK_VISIBLE_DEVICES=1 whisper-cli -m "$MODEL" -f "$1" -l "$LANG_CODE" \
        --no-timestamps --no-prints --suppress-nst 2>/dev/null \
      | tr '\n' ' ' | sed -E 's/\[[^]]*\]//g; s/\([^)]*\)//g; s/  +/ /g; s/^ +| +$//g'
}

deliver() {
    local text=$1
    bar
    [ -z "$text" ] && return
    if [ -n "$DICTATE_DRYRUN" ]; then printf '%s\n' "$text"; return; fi
    printf '%s' "$text" | wl-copy
    wtype -- "$text"
}

# --- test mode: transcribe a given file ---
if [ -n "$DICTATE_TEST_WAV" ]; then
    deliver "$(transcribe "$DICTATE_TEST_WAV")"
    exit 0
fi

# --- toggle ---
if [ -f "$PIDF" ] && kill -0 "$(cat "$PIDF")" 2>/dev/null; then
    # Stop recording (SIGINT lets pw-record finish the WAV header), then transcribe.
    kill -INT "$(cat "$PIDF")"
    while kill -0 "$(cat "$PIDF")" 2>/dev/null; do sleep 0.05; done
    rm -f "$PIDF"
    deliver "$(transcribe "$WAV")"
    rm -f "$WAV"
else
    rm -f "$WAV"
    # 16 kHz mono 16-bit is exactly what whisper expects, so no conversion step is needed.
    pw-record --rate 16000 --channels 1 --format s16 "$WAV" &
    echo $! > "$PIDF"
    bar rec
fi
