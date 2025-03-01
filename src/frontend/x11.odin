package frontend

import "core:fmt"
import "vendor:x11/xlib"

XDisplay: ^xlib.Display
XWindow: xlib.Window

init_x11 :: proc(width, height: u32) -> bool {
	XDisplay = xlib.OpenDisplay(nil)
	if XDisplay == nil {
		fmt.println("[ERROR] Failed to open X11 display")
		return false
	}

	root := xlib.DefaultRootWindow(XDisplay)

	XWindow = xlib.CreateSimpleWindow(
		XDisplay,
		root,
		10,
		10,
		width,
		height,
		1,
		xlib.BlackPixel(XDisplay, 0),
		xlib.WhitePixel(XDisplay, 0),
	)

	return true
}

