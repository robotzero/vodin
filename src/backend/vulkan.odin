package backend

import "core:fmt"
import "core:log"
import vk "vendor:vulkan"

foreign import VULKAN "system:vulkan"

@(default_calling_convention = "c", private)
foreign VULKAN {
	vkGetInstanceProcAddr :: proc(instance: vk.Instance, name: cstring) -> rawptr ---
}
@(private)
vulkanInstance: vk.Instance

initVulkan :: proc() -> bool {
	vk.load_proc_addresses_global(rawptr(vkGetInstanceProcAddr))

	if vk.CreateInstance == nil {
		fmt.println("[ERROR] Failed to load vkCreateInstance function pointer")
		return false
	}
	appInfo := vk.ApplicationInfo {
		sType              = .APPLICATION_INFO,
		pApplicationName   = "Vodin",
		applicationVersion = vk.MAKE_VERSION(1, 0, 0),
		pEngineName        = "Vulkan Odin Engine",
		engineVersion      = vk.MAKE_VERSION(1, 0, 0),
		apiVersion         = vk.API_VERSION_1_0,
	}

	instanceInfo := vk.InstanceCreateInfo {
		sType            = .INSTANCE_CREATE_INFO,
		pApplicationInfo = &appInfo,
	}

	must(vk.CreateInstance(&instanceInfo, nil, &vulkanInstance))
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

