# PCL.PW runtime — native part. Derived from Amethyst-Android (LGPL-3.0), see ../../../NOTICE.md
LOCAL_PATH := $(call my-dir)
HERE_PATH := $(LOCAL_PATH)

$(call import-module,prefab/xdl)

# androidnsbypass (MIT / BSD-2-Clause), built from source
LOCAL_PATH := $(HERE_PATH)/nsbypass
include $(CLEAR_VARS)
LOCAL_MODULE := androidnsbypass
LOCAL_SRC_FILES := jni.c elf_soname_patcher.c nsbypass.c utils.c android_linker_ns.cpp
LOCAL_C_INCLUDES := $(LOCAL_PATH)/include
LOCAL_EXPORT_C_INCLUDES := $(LOCAL_PATH)/include
LOCAL_CPPFLAGS := -std=c++17
LOCAL_LDLIBS := -llog
LOCAL_SHARED_LIBRARIES := xdl
include $(BUILD_SHARED_LIBRARY)

LOCAL_PATH := $(HERE_PATH)
include $(CLEAR_VARS)
LOCAL_MODULE := pojavexec
LOCAL_LDLIBS := -ldl -llog -landroid
LOCAL_C_INCLUDES := $(LOCAL_PATH)
LOCAL_SHARED_LIBRARIES := androidnsbypass
LOCAL_SRC_FILES := \
    bigcoreaffinity.c \
    egl_bridge.c \
    ctxbridges/loader_dlopen.c \
    ctxbridges/gl_bridge.c \
    ctxbridges/osm_bridge.c \
    ctxbridges/egl_loader.c \
    ctxbridges/osmesa_loader.c \
    ctxbridges/swap_interval_no_egl.c \
    environ/environ.c \
    jvm_hooks/emui_iterator_fix_hook.c \
    jvm_hooks/java_exec_hooks.c \
    jvm_hooks/lwjgl_dlopen_hook.c \
    input_bridge_v3.c \
    jre_launcher.c \
    utils.c \
    stdio_is.c
LOCAL_CFLAGS += -DADRENO_POSSIBLE
include $(BUILD_SHARED_LIBRARY)

# Fake library for the linker, deleted from the output by Gradle
include $(CLEAR_VARS)
LOCAL_MODULE := awt_headless
include $(BUILD_SHARED_LIBRARY)

# libawt_xawt without X11, copied into the JRE so AWT classes can load
LOCAL_PATH := $(HERE_PATH)/awt_xawt
include $(CLEAR_VARS)
LOCAL_MODULE := awt_xawt
LOCAL_SHARED_LIBRARIES := awt_headless
LOCAL_SRC_FILES := xawt_fake.c
include $(BUILD_SHARED_LIBRARY)
