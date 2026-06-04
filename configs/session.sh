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
# add split window
tmux split-window -h -t "$session:1" -c "$dir"
# run pi agent on 2nd pane
sleep 0.2
tmux send-keys -t "$session:1.1" 'w; pi --continue' C-m

tmux rename-window -t "$session:0" "git"
tmux rename-window -t "$session:1" "processing"

exec tmux attach-session -t "$session"
