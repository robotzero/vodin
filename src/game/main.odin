package game

import "../backend"
import "../frontend"
import "core:fmt"
import "core:strings"
import "core:time"

runGame :: proc() {
	defer frontend.cleanupWindow()
	defer backend.destroyVulkan()
	appName: cstring = "Vodin"
	success, screenData := frontend.createWindow(800, 600, appName)
	if !success {
		fmt.println("[ERROR] XCB initialization failed!")
		return
	}

	if !backend.initVulkan(screenData) {
		fmt.println("[ERROR] Vulkan initialization failed!")
		// frontend.cleanup_x11()
		return
	}

	for frontend.running {
		frontend.pollEvents()
		time.sleep(16 * time.Millisecond) // Placeholder for actual frame updates
	}
}

