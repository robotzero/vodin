package frontend

import "core:fmt"
import "vendor:x11/xlib"

foreign import X11XCB "system:X11-xcb"
foreign import XCBUTIL "system:xcb-util"

@(default_calling_convention = "c", private)
foreign X11XCB {
	XGetXCBConnection :: proc(_: ^xlib.Display) -> ^Connection ---
}
@(default_calling_convention = "c", private)
foreign XCBUTIL {
	xcb_aux_get_screen :: proc(connection: ^Connection, screen: i32) -> ^Screen ---
}
@(private = "file")
XDisplay: ^xlib.Display
@(private = "file")
XWindow: xlib.Window
@(private = "file")
xcbConnection: ^Connection
@(private = "file")
xcbWindow: u32
// @(private = "file")
running: bool = true

createWindow :: proc(width, height: u16) -> bool {
	screenp: i32
	xcbConnection = connect(nil, &screenp)
	result := connection_has_error(xcbConnection)
	if result != 0 {
		fmt.println("[ERROR] Failed to connect to XCB! %d", result)
	}
	if xcbConnection == nil {
		fmt.println("[ERROR] Failed to connecto to XCB!")
		return false
	}
	xcbWindow = generate_id(xcbConnection)

	screen := xcb_aux_get_screen(xcbConnection, screenp)
	values: [2]u32
	values[0] = screen.whitePixel
	values[1] = 0x000000 // Border color (black)
	// mask: u32 = Cw.BackPixel | Cw.EventMask

	create_window(
		xcbConnection,
		screen.rootDepth,
		xcbWindow,
		screen.root,
		0,
		0,
		width,
		height,
		0, // Border width
		auto_cast WindowClass.InputOutput, // Window class (InputOutput)
		screen.rootVisual,
		0,
		&values[0],
	)

	// change_property(
	// 	xcbConnection,
	// 	PropMode.Replace,
	// 	xcbWindow,
	// 	AtomEnum.AtomWmName,
	// 	AtomEnum.AtomString,
	// 	8,
	// 	cstring("12345677"),
	// )
	map_window(xcbConnection, xcbWindow)
	if flush(xcbConnection) != 1 {
		fmt.println("[ERROR] flush failed")
		return false
	}
	for true {

	}

	fmt.println("[INFO] XCB window create successfully!")
	return true
}

pollEvents :: proc() {
	for running {
		event := poll_for_event(xcbConnection)
		if event != nil {
			fmt.println("EVENT POLLING")
			continue
		}

		fmt.println("[EVENT] Received XCB event")
	}
}

cleanupWindow :: proc() {
	if xcbConnection != nil {
		disconnect(xcbConnection)
		fmt.println("[INFO] XCB connection closed.")
	}
}

initX11 :: proc(width, height: u32) -> bool {
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

