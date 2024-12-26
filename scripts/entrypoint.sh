#!/bin/sh
echo Starting stunnel

# Debian Stunnel service runs in the background
/etc/init.d/stunnel4 start

# Keep the container running
sleep infinity