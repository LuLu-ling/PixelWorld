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

# Turnip loader hook (Amethyst-Android, LGPL-3.0): loaded first into the namespace of the system
# Vulkan loader, so the loader opens libvulkan_freedreno.so instead of the vendor driver
LOCAL_PATH := $(HERE_PATH)/driver_helper/turnip
include $(CLEAR_VARS)
LOCAL_MODULE := linkerhook
LOCAL_LDLIBS := -llog
LOCAL_C_INCLUDES := $(HERE_PATH)
LOCAL_SHARED_LIBRARIES := androidnsbypass
LOCAL_SRC_FILES := hook.c
# Symbol lookup prefers this library over everything else
LOCAL_LDFLAGS := -z global
include $(BUILD_SHARED_LIBRARY)

# Single-window shim loaded by LWJGL in place of SDL3 (26.x); links libSDL3.so from jniLibs
LOCAL_PATH := $(HERE_PATH)/sdlshim
include $(CLEAR_VARS)
LOCAL_MODULE := pclpw_sdlshim
LOCAL_SRC_FILES := sdl_window_shim.c
LOCAL_LDLIBS := -ldl -llog
LOCAL_LDFLAGS := -L$(HERE_PATH)/../jniLibs/$(TARGET_ARCH_ABI) -lSDL3
LOCAL_DISABLE_FATAL_LINKER_WARNINGS := true
include $(BUILD_SHARED_LIBRARY)

LOCAL_PATH := $(HERE_PATH)
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
