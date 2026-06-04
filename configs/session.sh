#!/usr/bin/env bash
# example script with proper background processes setup
# allows to do fg with vim
dir="/mnt/c/Users/_/Desktop/"
session="T"

tmux new-session -d -s "$session" -c "$dir"
sleep 0.2
tmux send-keys -t "$session" 'v .' C-m

tmux new-window -t "$session" -c "$dir"
sleep 0.2
tmux send-keys -t "$session:1" 'cd ../toolkit/; v .' C-m
exec tmux attach-session -t "$session"
