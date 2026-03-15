// /Users/hadialmusawi/Desktop/FeatherAutoClicker/FeatherAutoClicker/UI/Views/Tabs/BasicTabView.swift
// this is the basic tab view

import SwiftUI
import AppKit
import Carbon.HIToolbox
import ApplicationServices

enum ClickType {
    case single
    case double
}

enum MouseButton: String {
    case none = "Bind Mouse Button"
    case m1 = "Left Mouse Button"
    case m2 = "Right Mouse Button"
    case m3 = "Middle Mouse Button"
    case m4 = "Side Mouse Button 2"
    case m5 = "Side Mouse Button 1"
}

struct BasicTabView: View {
    @ObservedObject var state: ClickerState
    @State private var isHovering = false // State to track hover
    @State private var isLeftClick = false  // For Left Click
    @State private var isRightClick = false  // For Right Click
    @State private var isDoubleClick = false  // For Double Click
    @State private var clickType: ClickType = .single  // Default to single click
    @State private var isHotkeyMode: Bool = true  // Set to true by default
    @State private var isHoldMode: Bool = false
    @State private var selectedMode: String = "hotkey" // Default to hotkey mode
    @State private var selectedMouseButton: MouseButton = .none
    @State private var selectedPattern: String = "Click Type"  // Add this at the top with other @State variables
    @State private var advancedLeftClick = false
    @State private var advancedRightClick = false
    @State private var isSelectingHotkey = false
    @State private var selectedHotkey = "Set Hotkey"
    @State private var hotkeyMonitor: Any?
    @State private var holdModeMonitor: Any?
    @State private var advancedHotkeyMonitor: Any?
    @State private var isSelectingAdvancedHotkey = false
    @State private var advancedSelectedHotkey = "Set Hotkey"
    @State private var showAlert = false // Add this for the alert
    @State private var basicLeftClick = false
    @State private var basicRightClick = false
    @State private var leftClickCount: Int = 0
    @State private var rightClickCount: Int = 0
    @State private var isAdvancedHovering = false // New state for advanced tooltip

    // Helper function to check if any click type is selected
    private func isAnyClickSelected() -> Bool {
        // Check basic clicks
        if basicLeftClick || basicRightClick {
            return true
        }
        // Check advanced clicks
        if advancedLeftClick || advancedRightClick {
            return true
        }
        return false
    }
    
    // Function to handle start button click
    private func handleStartClick() {
        if !isAnyClickSelected() {
            showAlert = true
            return
        }
        // Update the state directly
        state.isActive = true
    }

    var body: some View {
        ZStack {
            // Main content
            VStack(spacing: 15) {
                VStack(spacing: 8) { // test that out!!
                    // SPEED (CPS) text
                    Text("SPEED (CPS)")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 28)
                        .padding(.top, -267)

                    // Slider and CPS Display
                    HStack {
                        // Speed value (simple text)
                        Text("\(String(format: "%.1f", state.speed))")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(.blue)
                            .frame(width: 45)
                            .multilineTextAlignment(.center)
                            .padding(.leading, 32)
                        
                        Slider(value: $state.speed, in: 1...50)
                            .tint(.blue)
                            .frame(width: 280)
                            .padding(.leading, -4)
                        
                        Divider()
                            .frame(height: 20)
                            .padding(.horizontal, 8)
                        
                        HStack(spacing: 0) {
                            Toggle("Spike", isOn: $state.isSpiked)
                                .font(.system(size: 12, weight: .medium, design: .rounded))
                                .frame(width: 70)
                            
                            Image(systemName: "info.circle")
                                .foregroundColor(.gray)
                                .padding(.leading, 4)
                                .onHover { hovering in
                                    isHovering = hovering
                                }
                                .popover(isPresented: $isHovering, arrowEdge: .bottom) {
                                    Text("Randomly spikes CPS by +1 or -1 to appear natural \nand avoid detection by anti-cheats.")
                                        .font(.caption)
                                        .padding(10)
                                        .background(Color.black.opacity(0.8))
                                        .foregroundColor(.white)
                                        .multilineTextAlignment(.center)
                                        .cornerRadius(6)
                                }
                        }
                        .frame(width: 90)
                        .padding(.trailing, 40)
                    }
                    .frame(width: 500)  // Reduced overall width
                    .padding(.vertical, 8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(Color.black.opacity(0.2), lineWidth: 1)
                    )
                    .padding(.horizontal, 12)
                    .padding(.top, -257)

                    // BASIC and ADVANCED boxes
                    HStack(spacing: 140) {  // Boxes container
                        // Basic Box
                        VStack(alignment: .leading, spacing: 4) {
                            Text("BASIC")
                                .font(.system(size: 13, weight: .medium, design: .rounded))
                                .foregroundColor(.secondary)
                                .padding(.leading, 4)
                            
                            // Basic Box content
                            VStack(alignment: .leading) {
                                // Hotkey Mode Checkbox
                                HStack {
                                    Button(action: {
                                        isHotkeyMode.toggle()
                                        isHoldMode.toggle()
                                        selectedMode = isHotkeyMode ? "hotkey" : "hold"
                                        
                                        // Clean up all hotkey monitors when switching modes
                                        if let (global, local) = hotkeyMonitor as? (Any, Any) {
                                            NSEvent.removeMonitor(global)
                                            NSEvent.removeMonitor(local)
                                            hotkeyMonitor = nil
                                        }
                                        if let (global, local) = advancedHotkeyMonitor as? (Any, Any) {
                                            NSEvent.removeMonitor(global)
                                            NSEvent.removeMonitor(local)
                                            advancedHotkeyMonitor = nil
                                        }
                                        
                                        // Reset hotkeys and states
                                        selectedHotkey = "Set Hotkey"
                                        advancedSelectedHotkey = "Set Hotkey"
                                        
                                        // Reset Basic options when switching to Hold Mode
                                        if isHoldMode {
                                            basicLeftClick = false
                                            basicRightClick = false
                                            state.isLeftClick = false
                                            state.isRightClick = false
                                            selectedPattern = "Click Type"
                                            leftClickCount = 0
                                            rightClickCount = 0
                                            selectedHotkey = "Set Hotkey"
                                            
                                            // Clean up basic hotkey monitor
                                            if let (global, local) = hotkeyMonitor as? (Any, Any) {
                                                NSEvent.removeMonitor(global)
                                                NSEvent.removeMonitor(local)
                                                hotkeyMonitor = nil
                                            }
                                        }
                                        
                                        // Add this block to reset counters when switching to Hotkey Mode
                                        if isHotkeyMode {
                                            leftClickCount = 0
                                            rightClickCount = 0
                                        }
                                        
                                        // Reset Advanced options when switching to Hotkey Mode
                                        if !isHoldMode {
                                            advancedLeftClick = false
                                            advancedRightClick = false
                                            selectedMouseButton = .none
                                        }
                                        
                                        // Ensure clicker is stopped
                                        state.isActive = false
                                    }) {
                                        HStack(spacing: 8) {
                                            Image(systemName: isHotkeyMode ? "checkmark.square.fill" : "square")
                                                .foregroundColor(isHotkeyMode ? .blue : .gray)
                                                .font(.system(size: 16))
                                            
                                            Text("Hotkey Mode")
                                                .font(.system(size: 14, weight: .black))
                                                .foregroundColor(.primary)
                                        }
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                                .padding(.top, 27)  // Keeping Hotkey Mode at 22
                                .padding(.leading, 4)
                                
                                // Group all other Basic options
                                Group {
                                    // Set Hotkey Button
                                    Button(action: {
                                        // Remove any existing monitors first
                                        if let monitor = hotkeyMonitor {
                                            if let (global, local) = monitor as? (Any, Any) {
                                                NSEvent.removeMonitor(global)
                                                NSEvent.removeMonitor(local)
                                            }
                                            hotkeyMonitor = nil
                                        }
                                        
                                        isSelectingHotkey = true
                                        selectedHotkey = "..."
                                        
                                        let localMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
                                            if isSelectingHotkey {
                                                let key = event.charactersIgnoringModifiers?.uppercased() ?? ""
                                                if !key.isEmpty {
                                                    selectedHotkey = key
                                                    isSelectingHotkey = false
                                                    setupNewHotkeyMonitor(for: key, isAdvanced: false)
                                                }
                                                return nil
                                            }
                                            return event
                                        }
                                        hotkeyMonitor = localMonitor
                                    }) {
                                        Text(selectedHotkey)
                                            .font(.system(size: 14))
                                            .foregroundColor(.white)
                                            .frame(width: 150, height: 32)
                                            .background(Color(.darkGray).opacity(0.3))
                                            .cornerRadius(6)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 6)
                                                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                            )
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    .padding(.top, 8)
                                    .padding(.leading, 4)
                                    
                                    // Click Type Dropdown (without title, single click default)
                                    NSTableViewDropdownWrapper(
                                        selectedPattern: .constant("Single Click"), // Default to "Single Click"
                                        options: ["Single Click", "Double Click"]
                                    )
                                    .frame(maxWidth: 150)
                                    .background(Color.gray.opacity(0.1))
                                    .padding(.top, 8)
                                    .padding(.leading, 4)
                                    
                                    // Left Click Checkbox
                                    HStack {
                                        Button(action: {
                                            if !isHoldMode {
                                                basicLeftClick = true
                                                basicRightClick = false
                                                state.isLeftClick = true
                                                state.isRightClick = false
                                            }
                                        }) {
                                            HStack(spacing: 8) {
                                                Image(systemName: basicLeftClick ? "checkmark.square.fill" : "square")
                                                    .foregroundColor(basicLeftClick ? .blue : .gray)
                                                    .font(.system(size: 16))
                                                
                                                Text("Left Click")
                                                    .font(.system(size: 14, weight: .medium))
                                                    .foregroundColor(.primary)
                                            }
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                        .disabled(isHoldMode)
                                    }
                                    .padding(.top, 8)
                                    .padding(.leading, 4)
                                    
                                    // Right Click Checkbox
                                    HStack {
                                        Button(action: {
                                            if !isHoldMode {
                                                basicRightClick = true
                                                basicLeftClick = false
                                                state.isLeftClick = false
                                                state.isRightClick = true
                                            }
                                        }) {
                                            HStack(spacing: 8) {
                                                Image(systemName: basicRightClick ? "checkmark.square.fill" : "square")
                                                    .foregroundColor(basicRightClick ? .blue : .gray)
                                                    .font(.system(size: 16))
                                                
                                                Text("Right Click")
                                                    .font(.system(size: 14, weight: .medium))
                                                    .foregroundColor(.primary)
                                            }
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                        .disabled(isHoldMode)
                                    }
                                    .padding(.top, 8)
                                    .padding(.leading, 4)
                                }
                                .opacity(isHoldMode ? 0.5 : 1)
                                .disabled(isHoldMode)
                            }
                            .frame(width: 180, height: 200)
                            .offset(y: -16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(Color.black.opacity(0.2), lineWidth: 1)
                            )
                        }
                        
                        // Advanced Box
                        VStack(alignment: .leading, spacing: 4) {
                            HStack(spacing: 4) {
                                Text("ADVANCED")
                                    .font(.system(size: 13, weight: .medium, design: .rounded))
                                    .foregroundColor(.secondary)
                                
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(Color(red: 1.0, green: 0.9, blue: 0.0))
                                    .font(.system(size: 11))
                                    .onHover { hovering in
                                        isAdvancedHovering = hovering
                                    }
                                    .popover(isPresented: $isAdvancedHovering, arrowEdge: .bottom) {
                                        Text("Binding as Left/Right Mouse Button while click type is Left/Right Click \nis not recommended and may cause issues.")
                                            .font(.caption)
                                            .padding(10)
                                            .background(Color.black.opacity(0.8))
                                            .foregroundColor(.white)
                                            .multilineTextAlignment(.center)
                                            .cornerRadius(6)
                                    }
                            }
                            .padding(.leading, 4)
                            
                            // Advanced Box content
                            VStack(alignment: .leading) {
                                // Hold Mode Checkbox
                                HStack {
                                    Button(action: {
                                        isHoldMode.toggle()
                                        isHotkeyMode.toggle()
                                        selectedMode = isHoldMode ? "hold" : "hotkey"
                                        
                                        // Reset Basic options when switching to Hold Mode
                                        if isHoldMode {
                                            basicLeftClick = false
                                            basicRightClick = false
                                            state.isLeftClick = false
                                            state.isRightClick = false
                                            selectedPattern = "Click Type"
                                            leftClickCount = 0
                                            rightClickCount = 0
                                            selectedHotkey = "Set Hotkey" // Reset basic hotkey
                                            
                                            // Clean up basic hotkey monitor
                                            if let (global, local) = hotkeyMonitor as? (Any, Any) {
                                                NSEvent.removeMonitor(global)
                                                NSEvent.removeMonitor(local)
                                                hotkeyMonitor = nil
                                            }
                                        }
                                        
                                        // Reset Advanced options when switching to Hotkey Mode
                                        if !isHoldMode {
                                            advancedLeftClick = false
                                            advancedRightClick = false
                                            selectedMouseButton = .none
                                        }
                                        
                                        // Ensure clicker is stopped
                                        state.isActive = false
                                    }) {
                                        HStack(spacing: 8) {
                                            Image(systemName: isHoldMode ? "checkmark.square.fill" : "square")
                                                .foregroundColor(isHoldMode ? .blue : .gray)
                                                .font(.system(size: 16))
                                            
                                            Text("Hold Mode")
                                                .font(.system(size: 14, weight: .black))
                                                .foregroundColor(.primary)
                                        }
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                                .padding(.top, 26)
                                .padding(.leading, 8)
                                
                                // Group all other Advanced options
                                Group {
                                    // Set Hotkey Button
                                    Button(action: {
                                        // Remove any existing monitors first
                                        if let monitor = advancedHotkeyMonitor {
                                            if let (global, local) = monitor as? (Any, Any) {
                                                NSEvent.removeMonitor(global)
                                                NSEvent.removeMonitor(local)
                                            }
                                            advancedHotkeyMonitor = nil
                                        }
                                        
                                        isSelectingAdvancedHotkey = true
                                        advancedSelectedHotkey = "..."
                                        
                                        let localMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
                                            if isSelectingAdvancedHotkey {
                                                let key = event.charactersIgnoringModifiers?.uppercased() ?? ""
                                                if !key.isEmpty {
                                                    advancedSelectedHotkey = key
                                                    isSelectingAdvancedHotkey = false
                                                    setupNewHotkeyMonitor(for: key, isAdvanced: true)
                                                }
                                                return nil
                                            }
                                            return event
                                        }
                                        advancedHotkeyMonitor = localMonitor
                                    }) {
                                        Text(advancedSelectedHotkey)
                                            .font(.system(size: 14))
                                            .foregroundColor(.white)
                                            .frame(width: 150, height: 32)
                                            .background(Color(.darkGray).opacity(0.3))
                                            .cornerRadius(6)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 6)
                                                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                            )
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    .padding(.top, 8)
                                    .padding(.leading, 8)
                                    
                                    // Mouse Button Dropdown
                                    NSTableViewDropdownWrapper(
                                        selectedPattern: Binding(
                                            get: { 
                                                switch selectedMouseButton {
                                                case .none: return "Bind Mouse Button"
                                                case .m1: return "Left Mouse Button"
                                                case .m2: return "Right Mouse Button"
                                                case .m3: return "Middle Mouse Button"
                                                case .m4: return "Side Mouse Button 2"
                                                case .m5: return "Side Mouse Button 1"
                                                }
                                            },
                                            set: { newValue in
                                                switch newValue {
                                                case "Left Mouse Button": selectedMouseButton = .m1
                                                case "Right Mouse Button": selectedMouseButton = .m2
                                                case "Middle Mouse Button": selectedMouseButton = .m3
                                                case "Side Mouse Button 2": selectedMouseButton = .m4
                                                case "Side Mouse Button 1": selectedMouseButton = .m5
                                                default: break
                                                }
                                            }
                                        ),
                                        options: ["Left Mouse Button", "Right Mouse Button", "Middle Mouse Button", "Side Mouse Button 2", "Side Mouse Button 1"]
                                    )
                                    .frame(maxWidth: 150)
                                    .background(Color.gray.opacity(0.1))
                                    .padding(.top, 8)
                                    .padding(.leading, 8)
                                    
                                    // Advanced Left Click
                                    Button(action: {
                                        if !advancedLeftClick {
                                            advancedLeftClick = true
                                            advancedRightClick = false
                                            state.isLeftClick = true
                                            state.isRightClick = false
                                        }
                                    }) {
                                        HStack(spacing: 8) {
                                            Image(systemName: advancedLeftClick ? "checkmark.square.fill" : "square")
                                                .foregroundColor(advancedLeftClick ? .blue : .gray)
                                                .font(.system(size: 16))
                                            
                                            Text("Left Click")
                                                .font(.system(size: 14, weight: .medium))
                                                .foregroundColor(.primary)
                                        }
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    .padding(.top, 8)
                                    .padding(.leading, 8)
                                    
                                    // Advanced Right Click
                                    Button(action: {
                                        if !advancedRightClick {
                                            advancedRightClick = true
                                            advancedLeftClick = false
                                            state.isLeftClick = false
                                            state.isRightClick = true
                                        }
                                    }) {
                                        HStack(spacing: 8) {
                                            Image(systemName: advancedRightClick ? "checkmark.square.fill" : "square")
                                                .foregroundColor(advancedRightClick ? .blue : .gray)
                                                .font(.system(size: 16))
                                            
                                            Text("Right Click")
                                                .font(.system(size: 14, weight: .medium))
                                                .foregroundColor(.primary)
                                        }
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    .padding(.top, 8)
                                    .padding(.leading, 8)
                                }
                                .opacity(selectedMode == "hotkey" ? 0.5 : 1)
                                .disabled(selectedMode == "hotkey")
                            }
                            .frame(width: 180, height: 200)
                            .offset(y: -16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(Color.black.opacity(0.2), lineWidth: 1)
                            )
                        }
                    }
                    .offset(y: -25)
                    .padding(.top, -186)
                }
            }
            
            // Centered Start/Stop Buttons and Test Area
            VStack(spacing: 8) {
                // Start Button
                Button(action: handleStartClick) {
                    Text("Start")
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .frame(width: 80, height: 26)
                        .background(state.isActive ? Color.blue.opacity(0.3) : Color.blue.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(6)
                }
                .buttonStyle(.plain)
                .disabled(state.isActive)
                
                // Stop Button
                Button(action: { 
                    state.isActive = false 
                }) {
                    Text("Stop")
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .frame(width: 80, height: 26)
                        .background(state.isActive ? Color.blue.opacity(0.8) : Color.blue.opacity(0.3))
                        .foregroundColor(.white)
                        .cornerRadius(6)
                }
                .buttonStyle(.plain)
                .disabled(!state.isActive)
                
                // Test Box
                VStack(spacing: 4) {
                    Button(action: {}) {
                        Text("Test Autoclicker")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.primary)
                            .frame(width: 110, height: 30)
                            .background(Color.gray.opacity(0.15))
                            .cornerRadius(6)
                    }
                    .buttonStyle(.plain)
                    .background(TestClickerView(leftClickCount: $leftClickCount, rightClickCount: $rightClickCount))
                    
                    // Click Counter
                    Text("Clicks: \(leftClickCount):\(rightClickCount)")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 4)
                .padding(.horizontal, 6)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
                .padding(.top, 2)
            }
            .offset(y: -90)
        }
        .padding(.top, 190)
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Click Type Required"),
                message: Text("Please select a click type!"),
                dismissButton: .default(Text("OK"))
            )
        }
        .onDisappear {
            // Clean up all hotkey monitors
            if let (global, local) = hotkeyMonitor as? (Any, Any) {
                NSEvent.removeMonitor(global)
                NSEvent.removeMonitor(local)
                hotkeyMonitor = nil
            }
            if let (global, local) = advancedHotkeyMonitor as? (Any, Any) {
                NSEvent.removeMonitor(global)
                NSEvent.removeMonitor(local)
                advancedHotkeyMonitor = nil
            }
            
            // Reset all basic tab state
            basicLeftClick = false
            basicRightClick = false
            advancedLeftClick = false
            advancedRightClick = false
            isHotkeyMode = true
            isHoldMode = false
            selectedMode = "hotkey"
            selectedMouseButton = .none
            selectedPattern = "Click Type"
            isSelectingHotkey = false
            isSelectingAdvancedHotkey = false
            selectedHotkey = "Set Hotkey"
            advancedSelectedHotkey = "Set Hotkey"
            leftClickCount = 0
            rightClickCount = 0
            
            // Reset clicker state
            state.isLeftClick = false
            state.isRightClick = false
            state.isActive = false
            
            // Stop hold monitoring if active
            SimpleBridge.shared().stopMonitoringHold()
        }
        .onChange(of: isHoldMode) { _ in setupMouseHoldMonitoring() }
        .onChange(of: selectedMouseButton) { _ in setupMouseHoldMonitoring() }
        .onChange(of: advancedLeftClick) { _ in setupMouseHoldMonitoring() }
        .onChange(of: advancedRightClick) { _ in setupMouseHoldMonitoring() }
    }

    private func setupHotkeyMonitor(for key: String, isHoldMode: Bool) -> Any? {
        guard AXIsProcessTrusted() else {
            print("Accessibility permissions not granted")
            return nil
        }
        
        let eventMask: NSEvent.EventTypeMask = isHoldMode ? [.keyDown, .keyUp] : .keyDown
        
        // Global monitor for when app is not in focus
        let globalMonitor = NSEvent.addGlobalMonitorForEvents(matching: eventMask) { event in
            handleHotkeyEvent(event, key: key, isHoldMode: isHoldMode)
        }
        
        // Local monitor for when app is in focus
        let localMonitor = NSEvent.addLocalMonitorForEvents(matching: eventMask) { event in
            handleHotkeyEvent(event, key: key, isHoldMode: isHoldMode)
            return event
        }
        
        // Return both monitors as a tuple
        return (globalMonitor, localMonitor)
    }

    private func handleHotkeyEvent(_ event: NSEvent, key: String, isHoldMode: Bool) {
        // Don't handle events if we're selecting a new hotkey
        if isSelectingHotkey || isSelectingAdvancedHotkey {
            return
        }
        
        guard let pressedKey = event.charactersIgnoringModifiers?.uppercased(),
              pressedKey == key else { return }
        
        DispatchQueue.main.async {
            if event.type == .keyDown {
                if !isAnyClickSelected() {
                    showAlert = true
                    return
                }
                
                if state.isActive {
                    let (shouldSpike, addClick) = shouldSpikeClick()
                    if shouldSpike {
                        if addClick {
                            // Add an extra click
                            handleClick()
                        } else {
                            // Skip this click
                            return
                        }
                    }
                }
                
                state.isActive.toggle()
            }
        }
    }

    // Update the monitor setup function
    private func setupNewHotkeyMonitor(for key: String, isAdvanced: Bool) {
        if !AXIsProcessTrusted() {
            let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true]
            AXIsProcessTrustedWithOptions(options)
            return
        }
        
        // First, remove any existing monitors
        if let monitor = hotkeyMonitor {
            if let (global, local) = monitor as? (Any, Any) {
                NSEvent.removeMonitor(global)
                NSEvent.removeMonitor(local)
            }
            hotkeyMonitor = nil
        }
        
        if let monitor = advancedHotkeyMonitor {
            if let (global, local) = monitor as? (Any, Any) {
                NSEvent.removeMonitor(global)
                NSEvent.removeMonitor(local)
            }
            advancedHotkeyMonitor = nil
        }
        
        // Don't set up new monitor if we're in the process of selecting a hotkey
        if isSelectingHotkey || isSelectingAdvancedHotkey {
            return
        }
        
        // Create new monitor for the current hotkey
        let monitor = setupHotkeyMonitor(for: key, isHoldMode: isAdvanced)
        
        // Store the new monitor in the appropriate variable
        if isAdvanced {
            advancedHotkeyMonitor = monitor
        } else {
            hotkeyMonitor = monitor
        }
    }

    // Update your click handling function
    private func handleClick() {
        if state.isLeftClick {
            leftClickCount += 1
        } else if state.isRightClick {
            rightClickCount += 1
        }
    }
    
    // Add reset function for the counters
    private func resetCounters() {
        leftClickCount = 0
        rightClickCount = 0
    }

    private func setupMouseHoldMonitoring() {
        guard isHoldMode else {
            SimpleBridge.shared().stopMonitoringHold()
            return
        }
        
        guard selectedMouseButton != .none, advancedLeftClick || advancedRightClick else {
            SimpleBridge.shared().stopMonitoringHold()
            return
        }
        
        let buttonNumber: Int
        switch selectedMouseButton {
        case .m1: buttonNumber = 0
        case .m2: buttonNumber = 1
        case .m3: buttonNumber = 2
        case .m4: buttonNumber = 3
        case .m5: buttonNumber = 4
        case .none: return
        }
        
        let isRight = advancedRightClick
        
        SimpleBridge.shared().startMonitoringHold(buttonNumber, onDown: {
            DispatchQueue.main.async {
                self.state.isRightClick = isRight
                self.state.isLeftClick = !isRight
                self.state.isActive = true
                
                let (shouldSpike, addClick) = self.shouldSpikeClick()
                if shouldSpike && addClick {
                    // Add an extra click immediately
                    if isRight {
                        self.rightClickCount += 1
                    } else {
                        self.leftClickCount += 1
                    }
                }
            }
        }, onUp: {
            DispatchQueue.main.async {
                self.state.isActive = false
            }
        })
    }

    private func shouldSpikeClick() -> (Bool, Bool) {
        guard state.isSpiked else { return (false, false) }
        
        let random = Double.random(in: 0...1)
        if random <= 0.10 { // 10% chance
            let addClick = Bool.random() // 50/50 chance to add or skip
            return (true, addClick)
        }
        return (false, false)
    }
}

extension MouseButton: CaseIterable {}

struct TestClickerView: NSViewRepresentable {
    @Binding var leftClickCount: Int
    @Binding var rightClickCount: Int
    
    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        
        // Create event tap for mouse clicks
        let eventMask = NSEvent.EventTypeMask.leftMouseDown.union(.rightMouseDown)
        let eventTap = NSEvent.addLocalMonitorForEvents(matching: eventMask) { event in
            if event.type == .leftMouseDown {
                DispatchQueue.main.async {
                    self.leftClickCount += 1
                }
            } else if event.type == .rightMouseDown {
                DispatchQueue.main.async {
                    self.rightClickCount += 1
                }
            }
            return event
        }
        
        // Store the event tap
        context.coordinator.eventTap = eventTap
        return view
    }
    
    func updateNSView(_ nsView: NSView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject {
        var parent: TestClickerView
        var eventTap: Any?
        
        init(_ parent: TestClickerView) {
            self.parent = parent
        }
        
        deinit {
            if let eventTap = eventTap {
                NSEvent.removeMonitor(eventTap)
            }
        }
    }
}
