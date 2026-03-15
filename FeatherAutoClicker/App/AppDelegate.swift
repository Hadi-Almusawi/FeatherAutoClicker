import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    var windowController: WindowController?
    
    static func main() {
        let app = NSApplication.shared
        let delegate = AppDelegate()
        app.delegate = delegate
        app.run()
    }
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Create and show main window
        windowController = WindowController()
        
        if let window = windowController?.window {
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
        }
        
        // Close any other windows that might be open
        NSApplication.shared.windows.forEach { window in
            if window != windowController?.window {
                window.close()
            }
        }
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
} 