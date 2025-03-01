package backend

import vk "vendor:vulkan"

// XcbSurfaceCreateFlagsKHR :: distinct bit_set[XcbSurfaceCreateFlagKHR;vk.Flags]
// XcbSurfaceCreateFlagKHR :: enum u32 {}
// XcbSurfaceCreateInfoKHR :: struct {
// 	sType:      vk.StructureType,
// 	pNext:      rawptr,
// 	flags:      XcbSurfaceCreateFlagsKHR,
// 	connection: ^Connection,
// 	window:     Window,
// }

// ProcCreateXcbSurfaceKHR :: #type proc "system" (
// 	instance: vk.Instance,
// 	pCreateInfo: ^XcbSurfaceCreateInfoKHR,
// 	pAllocator: ^vk.AllocationCallbacks,
// 	pSurface: ^vk.SurfaceKHR,
// ) -> vk.Result

// CreateXcbSurfaceKHR: ProcCreateXcbSurfaceKHR

// load_proc_addresses_custom :: proc(set_proc_address: vk.SetProcAddressType) {
// 	set_proc_address(&CreateXcbSurfaceKHR, cstring("vkCreateXcbSurfaceKHR"))
// }

load_proc_adresses_instance :: proc(instance: vk.Instance) {
	// CreateXcbSurfaceKHR =
	// auto_cast vk.GetInstanceProcAddr(instance, cstring("vkCreateXcbSurfaceKHR"))
	vk.EnumeratePhysicalDevices =
	auto_cast vkGetInstanceProcAddr(instance, cstring("vkEnumeratePhysicalDevices"))
	vk.GetPhysicalDeviceProperties =
	auto_cast vkGetInstanceProcAddr(instance, cstring("vkGetPhysicalDeviceProperties"))
	vk.GetPhysicalDeviceFeatures =
	auto_cast vkGetInstanceProcAddr(instance, cstring("vkGetPhysicalDeviceFeatures"))
	vk.GetPhysicalDeviceMemoryProperties =
	auto_cast vkGetInstanceProcAddr(instance, cstring("vkGetPhysicalDeviceMemoryProperties"))
	vk.GetPhysicalDeviceQueueFamilyProperties =
	auto_cast vkGetInstanceProcAddr(instance, cstring("vkGetPhysicalDeviceQueueFamilyProperties"))
	vk.GetPhysicalDeviceSurfaceSupportKHR =
	auto_cast vkGetInstanceProcAddr(instance, cstring("vkGetPhysicalDeviceSurfaceSupportKHR"))
	vk.GetPhysicalDeviceSurfaceCapabilitiesKHR =
	auto_cast vkGetInstanceProcAddr(instance, cstring("vkGetPhysicalDeviceSurfaceCapabilitiesKHR"))

	vk.GetPhysicalDeviceSurfaceFormatsKHR =
	auto_cast vkGetInstanceProcAddr(instance, cstring("vkGetPhysicalDeviceSurfaceFormatsKHR"))
	vk.GetPhysicalDeviceSurfacePresentModesKHR =
	auto_cast vkGetInstanceProcAddr(instance, cstring("vkGetPhysicalDeviceSurfacePresentModesKHR"))
	vk.EnumerateDeviceExtensionProperties =
	auto_cast vkGetInstanceProcAddr(instance, cstring("vkEnumerateDeviceExtensionProperties"))
	vk.CreateDevice = auto_cast vkGetInstanceProcAddr(instance, cstring("vkCreateDevice"))
	vk.GetDeviceQueue = auto_cast vkGetInstanceProcAddr(instance, cstring("vkGetDeviceQueue"))
	vk.DestroySurfaceKHR =
	auto_cast vk.GetInstanceProcAddr(instance, cstring("vkDestroySurfaceKHR"))
	vk.DestroyInstance = auto_cast vkGetInstanceProcAddr(instance, cstring("vkDestroyInstance"))
	vk.DestroyDevice = auto_cast vkGetInstanceProcAddr(instance, cstring("vkDestroyDevice"))
	vk.CreateSwapchainKHR =
	auto_cast vkGetInstanceProcAddr(instance, cstring("vkCreateSwapchainKHR"))
	vk.GetSwapchainImagesKHR =
	auto_cast vkGetInstanceProcAddr(instance, cstring("vkGetSwapchainImagesKHR"))
	vk.CreateImageView = auto_cast vk.GetInstanceProcAddr(instance, cstring("vkCreateImageView"))
	vk.GetPhysicalDeviceFormatProperties =
	auto_cast vkGetInstanceProcAddr(instance, cstring("vkGetPhysicalDeviceFormatProperties"))
	vk.CreateImage = auto_cast vk.GetInstanceProcAddr(instance, cstring("vkCreateImage"))
	vk.GetImageMemoryRequirements =
	auto_cast vkGetInstanceProcAddr(instance, cstring("vkGetImageMemoryRequirements"))
	vk.AllocateMemory = auto_cast vkGetInstanceProcAddr(instance, cstring("vkAllocateMemory"))
	vk.BindImageMemory = auto_cast vkGetInstanceProcAddr(instance, cstring("vkBindImageMemory"))
	vk.DestroyImageView = auto_cast vkGetInstanceProcAddr(instance, cstring("vkDestroyImageView"))
	vk.DestroySwapchainKHR =
	auto_cast vkGetInstanceProcAddr(instance, cstring("vkDestroySwapchainKHR"))
	vk.DestroyImage = auto_cast vkGetInstanceProcAddr(instance, cstring("vkDestroyImage"))
	vk.FreeMemory = auto_cast vkGetInstanceProcAddr(instance, cstring("vkFreeMemory"))
	vk.CreateRenderPass = auto_cast vkGetInstanceProcAddr(instance, cstring("vkCreateRenderPass"))
	vk.DestroyRenderPass =
	auto_cast vkGetInstanceProcAddr(instance, cstring("vkDestroyRenderPass"))
	vk.CreateCommandPool =
	auto_cast vkGetInstanceProcAddr(instance, cstring("vkCreateCommandPool"))
	vk.AllocateCommandBuffers =
	auto_cast vkGetInstanceProcAddr(instance, cstring("vkAllocateCommandBuffers"))
	vk.FreeCommandBuffers =
	auto_cast vkGetInstanceProcAddr(instance, cstring("vkFreeCommandBuffers"))
	vk.DestroyCommandPool =
	auto_cast vkGetInstanceProcAddr(instance, cstring("vkDestroyCommandPool"))
	vk.CreateFramebuffer =
	auto_cast vkGetInstanceProcAddr(instance, cstring("vkCreateFramebuffer"))
	vk.CreateSemaphore = auto_cast vkGetInstanceProcAddr(instance, cstring("vkCreateSemaphore"))
	vk.CreateFence = auto_cast vkGetInstanceProcAddr(instance, cstring("vkCreateFence"))
	vk.DeviceWaitIdle = auto_cast vkGetInstanceProcAddr(instance, cstring("vkDeviceWaitIdle"))
	vk.DestroySemaphore = auto_cast vkGetInstanceProcAddr(instance, cstring("vkDestroySemaphore"))
	vk.DestroyFence = auto_cast vkGetInstanceProcAddr(instance, cstring("vkDestroyFence"))
	vk.DestroyFramebuffer =
	auto_cast vkGetInstanceProcAddr(instance, cstring("vkDestroyFramebuffer"))
	vk.AcquireNextImageKHR =
	auto_cast vkGetInstanceProcAddr(instance, cstring("vkAcquireNextImageKHR"))
	vk.BeginCommandBuffer =
	auto_cast vkGetInstanceProcAddr(instance, cstring("vkBeginCommandBuffer"))
	vk.CmdSetViewport = auto_cast vkGetInstanceProcAddr(instance, cstring("vkCmdSetViewport"))
	vk.CmdSetScissor = auto_cast vkGetInstanceProcAddr(instance, cstring("vkCmdSetScissor"))
	vk.CmdBeginRenderPass =
	auto_cast vkGetInstanceProcAddr(instance, cstring("vkCmdBeginRenderPass"))
	vk.QueueSubmit = auto_cast vkGetInstanceProcAddr(instance, cstring("vkQueueSubmit"))
	vk.CmdEndRenderPass = auto_cast vkGetInstanceProcAddr(instance, cstring("vkCmdEndRenderPass"))
	vk.EndCommandBuffer = auto_cast vkGetInstanceProcAddr(instance, cstring("vkEndCommandBuffer"))
	vk.ResetFences = auto_cast vkGetInstanceProcAddr(instance, cstring("vkResetFences"))
	vk.QueuePresentKHR = auto_cast vkGetInstanceProcAddr(instance, cstring("vkQueuePresentKHR"))
	vk.WaitForFences = auto_cast vkGetInstanceProcAddr(instance, cstring("vkWaitForFences"))
}

// load_proc_addresses :: proc {
// 	load_proc_addresses_custom,
// 	load_proc_adresses_instance,
// }

