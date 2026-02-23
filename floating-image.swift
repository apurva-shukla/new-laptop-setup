import Cocoa

let app = NSApplication.shared

guard CommandLine.arguments.count > 1,
      let image = NSImage(contentsOfFile: CommandLine.arguments[1]) else {
    fputs("Usage: floating-image <path>\n", stderr)
    exit(1)
}

let maxW: CGFloat = 1800
let maxH: CGFloat = 1050
let ratio = min(maxW / image.size.width, maxH / image.size.height, 1.0)
let w = image.size.width * ratio
let h = image.size.height * ratio

let panel = NSPanel(
    contentRect: NSMakeRect(0, 0, w, h),
    styleMask: [.titled, .closable, .resizable, .utilityWindow],
    backing: .buffered,
    defer: false
)
panel.level = .floating
panel.title = "Keyboard Layout"
panel.center()
panel.isReleasedWhenClosed = true

let iv = NSImageView(frame: panel.contentView!.bounds)
iv.image = image
iv.imageScaling = .scaleProportionallyUpOrDown
iv.autoresizingMask = [.width, .height]
panel.contentView?.addSubview(iv)
panel.makeKeyAndOrderFront(nil)
app.activate(ignoringOtherApps: true)

class QuitOnClose: NSObject, NSWindowDelegate {
    func windowWillClose(_ n: Notification) { NSApp.terminate(nil) }
}
let d = QuitOnClose()
panel.delegate = d

app.run()
