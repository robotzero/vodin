package game

import "../backend"
import "../frontend"
import "core:fmt"
import "core:time"

runGame :: proc() {
	defer frontend.cleanupWindow()
	if !frontend.createWindow(800, 600) {
		fmt.println("[ERROR] XCB initialization failed!")
		return
	}

	if !backend.initVulkan() {
		fmt.println("[ERROR] Vulkan initialization failed!")
		// frontend.cleanup_x11()
		return
	}

	for frontend.running {
		frontend.pollEvents()
		time.sleep(16 * time.Millisecond) // Placeholder for actual frame updates
	}

	// running: bool = true
	// for running {
	// 	fmt.println("[INFO] Game loop running...")
	// 	time.sleep(100 * time.Millisecond) // Placeholder for actual frame updates
	// }

	// frontend.cleanup_x11()
}

