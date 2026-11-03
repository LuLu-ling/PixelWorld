// PCL.PW — single-window shim for SDL3 on Android (LGPL-3.0, see ../../../../NOTICE.md)
//
// LWJGL loads this library instead of libSDL3.so (-Dorg.lwjgl.sdl.libname). It links against
// libSDL3.so, so every SDL symbol LWJGL looks up through this handle resolves to SDL itself,
// except the window functions below.
//
// Minecraft 26.x's OpenGL backend keeps a hidden utility window holding the GL context, creates
// a test window, and then the game window. SDL's Android video driver allows only one window
// ("Android only supports one window"), so all of them share the one real window here. It is
// reference counted and destroyed when the last user destroys it. A GL context is not tied to a
// window on EGL, so making it current on the shared window works for every user.

#include <dlfcn.h>
#include <stdint.h>
#include <pthread.h>
#include <android/log.h>

#define TAG "PCLPW-SDLShim"
#define LOGI(...) __android_log_print(ANDROID_LOG_INFO, TAG, __VA_ARGS__)
#define LOGE(...) __android_log_print(ANDROID_LOG_ERROR, TAG, __VA_ARGS__)

typedef void *(*create_window_fn)(const char *title, int w, int h, uint64_t flags);
typedef void *(*create_window_props_fn)(uint32_t props);
typedef void (*destroy_window_fn)(void *window);

static pthread_mutex_t lock = PTHREAD_MUTEX_INITIALIZER;
static void *window = NULL;
static int refs = 0;

__attribute__((constructor)) static void loaded(void) {
    LOGI("Loaded");
}

/** SDL's own function, never this library's override of it */
static void *real(const char *name, void *self) {
    void *f = dlsym(RTLD_NEXT, name);
    if (f == NULL || f == self) {
        void *handle = dlopen("libSDL3.so", RTLD_NOW);
        f = handle ? dlsym(handle, name) : NULL;
    }
    if (f == NULL || f == self) {
        LOGE("Cannot find SDL's %s", name);
        return NULL;
    }
    Dl_info info;
    if (dladdr(f, &info)) LOGI("%s -> %s", name, info.dli_fname);
    return f;
}

/** Takes a reference to the shared window; NULL if there is none yet */
static void *reuse(void) {
    pthread_mutex_lock(&lock);
    void *w = window;
    if (w != NULL) refs++;
    int n = refs;
    pthread_mutex_unlock(&lock);
    if (w != NULL) LOGI("Sharing the window with another user (%d users)", n);
    return w;
}

static void *created(void *w) {
    if (w == NULL) return NULL;
    pthread_mutex_lock(&lock);
    window = w;
    refs = 1;
    pthread_mutex_unlock(&lock);
    LOGI("Created the window %p", w);
    return w;
}

__attribute__((visibility("default")))
void *SDL_CreateWindow(const char *title, int w, int h, uint64_t flags) {
    static create_window_fn fn = NULL;
    LOGI("SDL_CreateWindow(\"%s\", %d, %d, 0x%llx)", title ? title : "", w, h, (unsigned long long) flags);
    void *shared = reuse();
    if (shared != NULL) return shared;
    if (fn == NULL) fn = (create_window_fn) real("SDL_CreateWindow", (void *) SDL_CreateWindow);
    return fn ? created(fn(title, w, h, flags)) : NULL;
}

__attribute__((visibility("default")))
void *SDL_CreateWindowWithProperties(uint32_t props) {
    static create_window_props_fn fn = NULL;
    LOGI("SDL_CreateWindowWithProperties(%u)", props);
    void *shared = reuse();
    if (shared != NULL) return shared;
    if (fn == NULL) fn = (create_window_props_fn) real("SDL_CreateWindowWithProperties", (void *) SDL_CreateWindowWithProperties);
    return fn ? created(fn(props)) : NULL;
}

__attribute__((visibility("default")))
void SDL_DestroyWindow(void *w) {
    static destroy_window_fn fn = NULL;
    pthread_mutex_lock(&lock);
    int keep = 0;
    if (w != NULL && w == window) {
        if (--refs > 0) keep = 1;
        else window = NULL;
    }
    int n = refs;
    pthread_mutex_unlock(&lock);
    if (keep) {
        LOGI("SDL_DestroyWindow(%p): kept for the other users (%d)", w, n);
        return;
    }
    LOGI("SDL_DestroyWindow(%p)", w);
    if (fn == NULL) fn = (destroy_window_fn) real("SDL_DestroyWindow", (void *) SDL_DestroyWindow);
    if (fn) fn(w);
}
