package backend

import "core:fmt"
import "core:log"
import vk "vendor:vulkan"

foreign import VLIB "system:vulkan"

@(default_calling_convention = "c", private)
foreign VLIB {
	vkGetInstanceProcAddr :: proc(instance: vk.Instance, name: cstring) -> rawptr ---
}
@(private)
vulkanInstance: vk.Instance

init_vulkan :: proc() -> bool {
	vk.load_proc_addresses_global(rawptr(vkGetInstanceProcAddr))

	if vk.CreateInstance == nil {
		fmt.println("[ERROR] Failed to load vkCreateInstance function pointer")
		return false
	}
	app_info := vk.ApplicationInfo {
		sType              = .APPLICATION_INFO,
		pApplicationName   = "Odin Vulkan Renderer",
		applicationVersion = vk.MAKE_VERSION(1, 0, 0),
		pEngineName        = "Odin Engine",
		engineVersion      = vk.MAKE_VERSION(1, 0, 0),
		apiVersion         = vk.API_VERSION_1_0,
	}

	instance_info := vk.InstanceCreateInfo {
		sType            = .INSTANCE_CREATE_INFO,
		pApplicationInfo = &app_info,
	}

	must(vk.CreateInstance(&instance_info, nil, &vulkanInstance))
	defer vk.DestroyInstance(vulkanInstance, nil)

	vk.load_proc_addresses_instance(vulkanInstance)
	// load_proc_adresses_instance(vulkanInstance)

	fmt.println("[INFO] Vulkan instance created successfully!")
	return true
}

must :: proc(result: vk.Result, loc := #caller_location) {
	if result != .SUCCESS {
		log.panicf("Vulkan failure %v", result, location = loc)
	}
}

