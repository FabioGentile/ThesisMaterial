#!/bin/bash

adb shell "su -c 'rm -f /sdcard/BENCHMARK/PowerTrace.log'"
adb shell "su -c 'mv /data/user/0/fabiogentile.powertutor/files/PowerTrace.log /sdcard/BENCHMARK/PowerTrace.log'"
adb pull /sdcard/BENCHMARK/PowerTrace.log PowerTrace.log
