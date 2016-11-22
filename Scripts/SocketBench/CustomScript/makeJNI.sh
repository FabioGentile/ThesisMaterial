#!/bin/bash

cd ../jni
ndk-build
cd ..

adb push ./libs/armeabi-v7a/SocketBench /sdcard/BENCHMARK
adb shell "su -c '/system/xbin/rm -f /system/xbin/SocketBench'" 
adb shell "su -c '/system/xbin/mv /sdcard/BENCHMARK/SocketBench /system/xbin'" 
adb shell "su -c 'chmod 777 /system/xbin/SocketBench'"
adb shell "su -c 'chown root:root /system/xbin/SocketBench'"
