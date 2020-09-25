#!/bin/bash
while true; do eval "$(cat /var/osbox/mypipe)" &>/var/osbox/pipereponse; done
