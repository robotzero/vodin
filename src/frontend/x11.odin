package frontend

import "core:fmt"

foreign import X11XCB "system:X11-xcb"
foreign import XCBUTIL "system:xcb-util"

@(default_calling_convention = "c", private)
foreign XCBUTIL {
	xcb_aux_get_screen :: proc(connection: ^Connection, screen: i32) -> ^Screen ---
}
@(private = "file")
xcbConnection: ^Connection
@(private = "file")
xcbWindow: u32
running: bool = true

createWindow :: proc(width, height: u16, appName: cstring) -> bool {
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
	eventValues: [3]u32
	eventValues[0] = screen.blackPixel
	eventValues[1] =
	cast(u32)(EventMask.ButtonPress |
		EventMask.ButtonRelease |
		EventMask.KeyPress |
		EventMask.KeyRelease |
		EventMask.Exposure |
		EventMask.StructureNotify)
	eventValues[2] = 0
	mask := cast(u32)(Cw.BackPixel | Cw.EventMask)

	cookie := create_window(
		xcbConnection,
		screen.rootDepth,
		xcbWindow,
		screen.root,
		0,
		0,
		width,
		height,
		0,
		auto_cast WindowClass.InputOutput,
		screen.rootVisual,
		mask,
		&eventValues[0],
	)

	change_property(
		xcbConnection,
		cast(u8)PropMode.Replace,
		xcbWindow,
		cast(u32)AtomEnum.AtomWmName,
		cast(u32)AtomEnum.AtomString,
		8,
		cast(u32)len(appName),
		cast(rawptr)appName,
	)
	map_window(xcbConnection, xcbWindow)
	if flush(xcbConnection) <= 0 {
		fmt.println("[ERROR] flush failed")
		return false
	}

	fmt.println("[INFO] XCB window create successfully!")
	return true
}

pollEvents :: proc() {
	event := poll_for_event(xcbConnection)
	if event != nil {
		switch (event.responseType & 0x7f) {
		case KEY_RELEASE, KEY_PRESS:
			kevent := cast(^KeyPressEvent)event
			code := kevent.detail
			if code == 9 {
				running = false
			}
		}
	}
}

cleanupWindow :: proc() {
	if xcbConnection != nil {
		disconnect(xcbConnection)
		fmt.println("[INFO] XCB connection closed.")
	}
}

