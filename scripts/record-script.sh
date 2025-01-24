#!/usr/bin/env bash

getdate() {
	date '+%Y-%m-%d_%H.%M.%S'
}
getaudiooutput() {
	pactl list sources | grep 'Name' | grep 'monitor' | cut -d ' ' -f2
}
getactivemonitor() {
	hyprctl monitors -j | jq -r '.[] | select(.focused == true) | .name'
}

mkdir -p $HOME/Videos/ScreenRecordings
cd $HOME/Videos/ScreenRecordings || exit
if pgrep wf-recorder >/dev/null; then
	pkill wf-recorder &
	notify-send "Recording Stopped" "Stopped" -a 'record-script.sh' &
else
	notify-send "Starting recording" 'recording_'"$(getdate)"'.mp4' -a 'record-script.sh'
	sleep 5
	if [[ "$1" == "--sound" ]]; then
		wf-recorder --pixel-format yuv420p -f './recording_'"$(getdate)"'.mp4' -t --geometry "$(slurp)" --audio="$(getaudiooutput)" &
		disown
	elif [[ "$1" == "--fullscreen-sound" ]]; then
		wf-recorder -o $(getactivemonitor) --pixel-format yuv420p -f './recording_'"$(getdate)"'.mp4' -t --audio="$(getaudiooutput)" &
		disown
	elif [[ "$1" == "--fullscreen" ]]; then
		wf-recorder -o $(getactivemonitor) --pixel-format yuv420p -f './recording_'"$(getdate)"'.mp4' -t &
		disown
	else
		wf-recorder --pixel-format yuv420p -f './recording_'"$(getdate)"'.mp4' -t --geometry "$(slurp)" &
		disown
	fi
fi
