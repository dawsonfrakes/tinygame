#define X(RET, NAME, ...) RET (*NAME)(__VA_ARGS__);
VK10_GLOBAL_FUNCTIONS
#undef X

VkInstance vk_instance;

void vulkan_init(void) {
#if OS_WINDOWS
    HMODULE vk_dll = LoadLibraryA("vulkan-1.dll");
    PFN_vkVoidFunction (*vkGetInstanceProcAddr)(VkInstance, u8*) =
        cast(PFN_vkVoidFunction (*)(VkInstance, u8*))
        GetProcAddress(vk_dll, "vkGetInstanceProcAddr");

#define X(RET, NAME, ...) NAME = cast(RET (*)(__VA_ARGS__)) vkGetInstanceProcAddr(null, #NAME);
    VK10_GLOBAL_FUNCTIONS
#undef X
#endif

    // static VkInstanceCreateInfo instance_create_info = {0};
    // instance_create_info.sType = VK_STRUCTURE_TYPE_INSTANCE_CREATE_INFO;
    // vkCreateInstance(&instance_create_info, &vk_instance);
}

void vulkan_deinit(void) {

}

void vulkan_resize(void) {

}

void vulkan_present(void) {

}
