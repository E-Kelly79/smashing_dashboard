#!/bin/bash

# Logger
exec > /home/pi/dashlog.log 2>&1

# Run this script in display 0 - the monitor
export DISPLAY=:0

# Wait for wifi
sleep 15

# If Chromium crashes, clear the crash flag
sed -i 's/"exited_cleanly":false/"exited_cleanly":true/'
/home/pi/.config/chromium/Default/Preferences
sed -i 's/"exit_type":"Crashed"/"exit_type":"Normal"/'
/home/pi/.config/chromium/Default/Preferences

# Run Chromium
chromium-browser --incognito --disable-infobars --disable-session-crashed-bubble --kiosk http://10.128.5.92:8080

# Hide the mouse from display
unclutter -idle 3

exit 0