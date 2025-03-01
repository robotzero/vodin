package game

import "../backend"
import "../frontend"
import "core:fmt"
import "core:time"

run_game :: proc() {
	if !frontend.init_x11(800, 600) {
		fmt.println("[ERROR] X11 initialization failed!")
		return
	}

	if !backend.init_vulkan() {
		fmt.println("[ERROR] Vulkan initialization failed!")
		// frontend.cleanup_x11()
		return
	}

	running: bool = true
	for running {
		fmt.println("[INFO] Game loop running...")
		time.sleep(100 * time.Millisecond) // Placeholder for actual frame updates
	}

	// frontend.cleanup_x11()
}

