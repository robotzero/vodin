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
@(private)
physicalDevices: [10]vk.PhysicalDevice
@(private)
deviceCount: u32
@(private)
selectedGPU: vk.PhysicalDevice

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

	vk.load_proc_addresses_instance(vulkanInstance)
	// load_proc_adresses_instance(vulkanInstance)

	enumerateGPUs()
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

	for i: u32 = 0; i < deviceCount; i += 1 {
		properties: vk.PhysicalDeviceProperties
		memoryProperties: vk.PhysicalDeviceMemoryProperties

		vk.GetPhysicalDeviceProperties(physicalDevices[i], &properties)
		vk.GetPhysicalDeviceMemoryProperties(physicalDevices[i], &memoryProperties)

		// GPU type
		gpuType := properties.deviceType
		gpuName := properties.deviceName
		vram: u64 = 0

		// Biggest VRAM
		for j: u32 = 0; j < memoryProperties.memoryHeapCount; j += 1 {
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
		if gpuType == .DISCRETE_GPU && (bestType != .DISCRETE_GPU || vram > bestVRAM) {
			isBetterGPU = true
		} else if gpuType == .INTEGRATED_GPU && bestType != .DISCRETE_GPU && vram > bestVRAM {
			isBetterGPU = true
		}
		if bestGPU == nil {
			fmt.println("[ERROR] no suitable gpu found")
		}

		selectBestGPU := bestGPU
		fmt.printf(
			"[INFO] Selected GPU: %s | VRAM: %d MB\n",
			properties.deviceName[:],
			bestVRAM / (1024 * 1024),
		)
	}
}

destroyVulkan :: proc() {
	defer vk.DestroyInstance(vulkanInstance, nil)
}

must :: proc(result: vk.Result, loc := #caller_location) {
	if result != .SUCCESS {log.panicf("Vulkan failure %v", result, location = loc)
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

