LOCAL_PATH := $(call my-dir)
include $(CLEAR_VARS)
LOCAL_MODULE    := SocketBench
LOCAL_C_INCLUDES := $(LOCAL_PATH)/lib
LOCAL_SRC_FILES := SocketBench.cpp sockwrap.c errlib.c
include $(BUILD_EXECUTABLE)
