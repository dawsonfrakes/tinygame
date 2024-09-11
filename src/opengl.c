#if TARGET_OS_WINDOWS
static void opengl_platform_init(void) {

}

static void opengl_platform_deinit(void) {

}

static void opengl_platform_present(void) {

}
#endif

static void opengl_init(void) {
    opengl_platform_init();
}

static void opengl_deinit(void) {
    opengl_platform_deinit();
}

static void opengl_resize(void) {

}

static void opengl_present(void) {
    opengl_platform_present();
}
