#!/bin/bash                                                                                                                                                                                                                                                    
# This script is intended to make switching between laptop and external displays easier when using i3+dmenu                                                                                                                                                    
# To run this script, map it to some shortcut in your i3 config, e.g:                                                                                                                                                                                          
# bindsym $mod+p exec --no-startup-id $config/display.sh                                                                                                                                                                                                       
# IMPORTANT: run chmod +x on the script to make it executable                                                                                                                                                                                                  
# The result is 4 options appearing in dmenu, from which you can choose                                                                                                                                                                                        
# This is your default laptop screen, detect by running `xrandr`                                                                                                                                                                                               
 INTERNAL_OUTPUT="LVDS-1"                                                                                                                                                                                                                                       
#INTERNAL_OUTPUT="eDP1"                                                                                                                                                                                   
# choices will be displayed in dmenu                                                                                                                                                                                                                           
choices="laptop\ndual\nexternal\nclone\ntest"                                                                                                                                                                                                                        
# Your choice in dmenu will determine what xrandr command to run                                                                                                                                                                                               
chosen=$(echo -e $choices | dmenu -i)                                                                                                                                                                                                                          
# This is used to determine which external display you have connected
# This may vary between OS. e.g VGA1 instead of VGA-1
if [ `xrandr | grep VGA1 | grep -c ' connected '` -eq 1 ]; then
        EXTERNAL_OUTPUT="VGA1"
fi
if [ `xrandr | grep DVI1 | grep -c ' connected '` -eq 1 ]; then
        EXTERNAL_OUTPUT="DVI1"
fi
if [ `xrandr | grep HDMI1 | grep -c ' connected '` -eq 1 ]; then
        EXTERNAL_OUTPUT="HDMI1"
fi
if [ `xrandr | grep HDMI2 | grep -c ' connected '` -eq 1 ]; then
        EXTERNAL_OUTPUT="HDMI2"
fi
if [ `xrandr | grep HDMI3 | grep -c ' connected '` -eq 1 ]; then
        EXTERNAL_OUTPUT="HDMI3"
fi
if [ `xrandr | grep DP1 | grep -c ' connected '` -eq 1 ]; then
        EXTERNAL_OUTPUT="DP1"
fi
if [ `xrandr | grep DP2 | grep -c ' connected '` -eq 1 ]; then
        EXTERNAL_OUTPUT="DP2"
fi
if [ `xrandr | grep DP3 | grep -c ' connected '` -eq 1 ]; then
        EXTERNAL_OUTPUT="DP3"
fi

# xrander will run and turn on the display you want, if you have an option for 3 displays, this will need some modifications
case "$chosen" in
    external) xrandr --output $INTERNAL_OUTPUT --off --output $EXTERNAL_OUTPUT --auto --primary ;;
    laptop) xrandr --output $INTERNAL_OUTPUT --auto --primary --output $EXTERNAL_OUTPUT --off ;;
    clone) xrandr --output $INTERNAL_OUTPUT --auto --output $EXTERNAL_OUTPUT --auto --same-as $INTERNAL_OUTPUT ;;
    dual) xrandr --output $INTERNAL_OUTPUT --auto --output $EXTERNAL_OUTPUT --auto --right-of $INTERNAL_OUTPUT --primary ;;
    test) xrandr --output "DP3" --auto --right-of $INTERNAL_OUTPUT --primary;;

esac
