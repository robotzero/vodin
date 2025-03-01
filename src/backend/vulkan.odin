package backend

import "core:fmt"
import vv "vendor:vulkan"

foreign import VLIB "system:vulkan"

@(default_calling_convention = "c", private)
foreign VLIB {
	vkGetInstanceProcAddr :: proc(instance: vv.Instance, name: cstring) -> rawptr ---
}
@(private = "file")
vulkanInstance: vv.Instance
vkCreateInstance: #type proc "system" (
	info: ^vv.InstanceCreateInfo,
	allocator: ^vv.AllocationCallbacks,
	instance: ^vv.Instance,
) -> vv.Result

init_vulkan :: proc() -> bool {
	vkCreateInstance = auto_cast vkGetInstanceProcAddr(nil, cstring("vkCreateInstance"))

	if vkCreateInstance == nil {
		fmt.println("[ERROR] Failed to load vkCreateInstance function pointer")
		return false
	}
	app_info := vv.ApplicationInfo {
		sType              = .APPLICATION_INFO,
		pApplicationName   = "Odin Vulkan Renderer",
		applicationVersion = vv.MAKE_VERSION(1, 0, 0),
		pEngineName        = "Odin Engine",
		engineVersion      = vv.MAKE_VERSION(1, 0, 0),
		apiVersion         = vv.API_VERSION_1_0,
	}

	instance_info := vv.InstanceCreateInfo {
		sType            = .INSTANCE_CREATE_INFO,
		pApplicationInfo = &app_info,
	}


	// load_proc_adresses_instance(vulkanInstance)
	if vkCreateInstance(&instance_info, nil, &vulkanInstance) != .SUCCESS {
		fmt.println("[ERROR] Failed to create Vulkan instance!")
		return false
	}

	fmt.println("[INFO] Vulkan instance created successfully!")
	return true
}

