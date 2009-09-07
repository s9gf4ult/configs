PIPE=$HOME/.xmonad/status
rm -f $PIPE
PATH=${PATH}:/sbin mkfifo -m 600 $PIPE
[ -p $PIPE ] || exit

# status bar
xmobar < $PIPE &

# go for it
xmonad > $PIPE &

# wait for xmonad
wait $!

killall xmobar
