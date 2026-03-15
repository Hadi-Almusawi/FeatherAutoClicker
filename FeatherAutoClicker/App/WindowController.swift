import Cocoa
import SwiftUI

class WindowController: NSWindowController {
    convenience init() {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 500, height: 440),
            styleMask: [.titled, .closable, .miniaturizable],
            backing: .buffered,
            defer: false
        )
        
        // Configure window
        window.center()
        window.title = "Feather Clicker"
        window.titlebarAppearsTransparent = true
        window.titleVisibility = .hidden
        window.styleMask.insert(.fullSizeContentView)
        window.isReleasedWhenClosed = false
        
        // Lock window size
        window.minSize = NSSize(width: 500, height: 440)
        window.maxSize = NSSize(width: 500, height: 440)
        
        // Set up content view
        let state = ClickerState()
        let contentView = ContentView().environmentObject(state)
        let hostingView = NSHostingView(rootView: contentView)
        window.contentView = hostingView
        
        self.init(window: window)
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
        window?.makeKeyAndOrderFront(nil)
    }
} 