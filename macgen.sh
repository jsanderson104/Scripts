#!/bin/bash
# Generate a MAC address - was used for FlexLM mac spoofing. ie moved my licenses to another server and need to fake-out flexlm.
hexchars="0123456789ABCDEF"
end=$( for i in {1..6} ; do echo -n ${hexchars:$(( $RANDOM % 16 )):1} ; done | sed -e 's/\(..\)/:\1/g' )
echo 00:60:2F$end
