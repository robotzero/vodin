package backend

import "../frontend"
import "core:fmt"
import "core:log"
import vk "vendor:vulkan"

foreign import VULKAN "system:vulkan"

@(default_calling_convention = "c", private)
foreign VULKAN {
	vkGetInstanceProcAddr :: proc(instance: vk.Instance, name: cstring) -> rawptr ---
	vkCreateXcbSurfaceKHR :: proc(instance: vk.Instance, pAllocator: ^vk.AllocationCallbacks, pSurface: ^vk.SurfaceKHR) -> vk.Result ---
}
@(private)
xcb_connection_t :: struct {
}
@(private)
vulkanInstance: vk.Instance
@(private)
physicalDevices: [10]vk.PhysicalDevice
@(private)
deviceCount: u32
@(private)
selectedGPU: vk.PhysicalDevice
@(private)
graphicsQueueFamilyIndex: int = -1
@(private)
presentQueueFamilyIndex: int = -1
@(private)
surface: vk.SurfaceKHR

initVulkan :: proc(screenData: frontend.screenData) -> bool {
	vk.load_proc_addresses_global(rawptr(vkGetInstanceProcAddr))
	vk.load_proc_addresses_global(rawptr(vkCreateXcbSurfaceKHR))

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

	vk.load_proc_addresses_instance(vulkanInstance)
	// load_proc_adresses_instance(vulkanInstance)

	createSurface(screenData)
	enumerateGPUs()
	// if !findQueueFamilies(selectedGPU, surface) {
	// 	fmt.println("[ERROR] Failed to find queue families.")
	// 	return false
	// }
	fmt.println("[INFO] Vulkan instance created successfully!")
	return true
}

enumerateGPUs :: proc() -> bool {
	must(vk.EnumeratePhysicalDevices(vulkanInstance, &deviceCount, nil))

	fmt.printfln("[INFO] Found %d physical GPUs", deviceCount)

	must(vk.EnumeratePhysicalDevices(vulkanInstance, &deviceCount, &physicalDevices[0]))
	if len(physicalDevices) == 0 {
		fmt.println("[INFO] No physical devices found")
		return false
	}

	for i: u32 = 0; i < deviceCount; i += 1 {
		properties: vk.PhysicalDeviceProperties
		vk.GetPhysicalDeviceProperties(physicalDevices[i], &properties)
		fmt.printf(
			"[INFO] GPU %d: %s (API Version %d.%d.%d)\n",
			i,
			properties.deviceName[:],
			API_VERSION_MAJOR(properties.apiVersion),
			API_VERSION_MINOR(properties.apiVersion),
			API_VERSION_PATCH(properties.apiVersion),
		)
	}

	selectBestGPU()
	return true
}

selectBestGPU :: proc() {
	bestGPU: vk.PhysicalDevice = nil
	bestVRAM: u64 = 0
	bestType: vk.PhysicalDeviceType = .OTHER

	for i in 0 ..< deviceCount {
		properties: vk.PhysicalDeviceProperties
		memoryProperties: vk.PhysicalDeviceMemoryProperties

		vk.GetPhysicalDeviceProperties(physicalDevices[i], &properties)
		vk.GetPhysicalDeviceMemoryProperties(physicalDevices[i], &memoryProperties)

		// GPU type
		gpuType := properties.deviceType
		gpuName := properties.deviceName
		vram: u64 = 0

		// Biggest VRAM
		for j in 0 ..< memoryProperties.memoryHeapCount {
			if (vk.MemoryHeapFlag.DEVICE_LOCAL in memoryProperties.memoryHeaps[j].flags) {
				vram = auto_cast memoryProperties.memoryHeaps[j].size
			}
		}

		fmt.printf(
			"[INFO] GPU %d: %s | Type: %d | VRAM: %d MB",
			i,
			gpuName,
			gpuType,
			vram / (1024 * 1024),
		)
		isBetterGPU := false

		if bestGPU == nil {
			isBetterGPU = true
		} else if gpuType == .DISCRETE_GPU && (bestType != .DISCRETE_GPU) {
			isBetterGPU = true
		} else if gpuType == bestType && vram > bestVRAM {
			isBetterGPU = true
		}

		if isBetterGPU {
			bestGPU = physicalDevices[i]
			bestVRAM = vram
			bestType = gpuType
		}
		if bestGPU == nil {
			fmt.println("[ERROR] no suitable gpu found")
		}

		selectBestGPU := bestGPU
		fmt.printf(
			"[INFO] Selected GPU: %s | Type: %d | VRAM: %d MB\n",
			properties.deviceName[:],
			bestType,
			bestVRAM / (1024 * 1024),
		)
	}
}

findQueueFamilies :: proc(device: vk.PhysicalDevice, surface: vk.SurfaceKHR) -> bool {
	queueCount: u32 = 0
	vk.GetPhysicalDeviceQueueFamilyProperties(device, &queueCount, nil)
	if queueCount == 0 {
		fmt.println("[ERROR] No queue families found.")
		return false
	}

	queueFamilies := make([dynamic]vk.QueueFamilyProperties, queueCount)
	defer delete_dynamic_array(queueFamilies)

	for i in 0 ..< queueCount {
		flags := queueFamilies[i].queueFlags

		if .GRAPHICS in flags && graphicsQueueFamilyIndex == -1 {
			graphicsQueueFamilyIndex = int(i)
		}

		supported: b32
		result := vk.GetPhysicalDeviceSurfaceSupportKHR(device, u32(i), surface, &supported)
		must(result)
		if supported && presentQueueFamilyIndex == -1 {
			presentQueueFamilyIndex = int(i)
		}

		if graphicsQueueFamilyIndex != -1 && presentQueueFamilyIndex != -1 {
			break
		}
	}

	if graphicsQueueFamilyIndex == -1 {
		fmt.println("[ERROR] No graphics-capable queue found.")
		return false
	}
	if presentQueueFamilyIndex == -1 {
		fmt.println("[ERROR] No present-capable queue found.")
		return false
	}

	fmt.printf("[INFO] Selected graphics queue family: %d\n", graphicsQueueFamilyIndex)
	fmt.printf("[INFO] Selected present queue family: %d\n", presentQueueFamilyIndex)

	return true
}

createSurface :: proc(screenData: frontend.screenData) -> bool {
	createInfo := vk.XcbSurfaceCreateInfoKHR {
		sType      = .XCB_SURFACE_CREATE_INFO_KHR,
		connection = cast(^vk.xcb_connection_t)screenData.xcbConnection,
		window     = screenData.xcbWindow,
	}

	must(vk.CreateXcbSurfaceKHR(vulkanInstance, &createInfo, nil, &surface))

	fmt.println("[INFO] XCB surface created successfully!")
	return true
}

destroyVulkan :: proc() {
	defer vk.DestroyInstance(vulkanInstance, nil)
}

must :: proc(result: vk.Result, loc := #caller_location) {
	if result != .SUCCESS {
		log.panicf("Vulkan failure %v", result, location = loc)
	}
}

API_VERSION_MINOR :: proc(version: u32) -> u32 {
	return (version >> 12) & 0x3FF
}

API_VERSION_MAJOR :: proc(version: u32) -> u32 {
	return version >> 22
}

API_VERSION_PATCH :: proc(version: u32) -> u32 {
	return version & 0xFFF
}

