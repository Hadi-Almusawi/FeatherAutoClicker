import SwiftUI
import AppKit

struct NSTableViewDropdownWrapper: NSViewRepresentable {
    @Binding var selectedPattern: String
    let options: [String]
    
    init(selectedPattern: Binding<String>, options: [String]) {
        self._selectedPattern = selectedPattern
        self.options = options
    }
    
    func makeNSView(context: Context) -> NSButton {
        let button = NSButton(frame: .zero)
        button.title = selectedPattern
        button.bezelStyle = .rounded
        button.target = context.coordinator
        button.action = #selector(Coordinator.showPopover(_:))
        return button
    }
    
    func updateNSView(_ nsView: NSButton, context: Context) {
        nsView.title = selectedPattern
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, NSTableViewDelegate, NSTableViewDataSource {
        var parent: NSTableViewDropdownWrapper
        var popover: NSPopover?
        
        init(_ parent: NSTableViewDropdownWrapper) {
            self.parent = parent
        }
        
        @objc func showPopover(_ sender: NSButton) {
            if popover?.isShown == true {
                popover?.close()
                return
            }
            
            let tableView = NSTableView()
            let column = NSTableColumn(identifier: NSUserInterfaceItemIdentifier("options"))
            column.width = 180
            tableView.addTableColumn(column)
            tableView.delegate = self
            tableView.dataSource = self
            tableView.headerView = nil
            tableView.selectionHighlightStyle = .regular
            tableView.backgroundColor = .clear
            
            let scrollView = NSScrollView()
            scrollView.documentView = tableView
            scrollView.hasVerticalScroller = false
            scrollView.frame = NSRect(x: 0, y: 0, width: 200, height: 120)
            
            let contentView = NSVisualEffectView()
            contentView.material = .menu
            contentView.state = .active
            contentView.blendingMode = .behindWindow
            contentView.frame = scrollView.frame
            contentView.addSubview(scrollView)
            
            popover = NSPopover()
            popover?.contentSize = NSSize(width: 200, height: 120)
            popover?.behavior = .transient
            popover?.contentViewController = NSViewController()
            popover?.contentViewController?.view = contentView
            popover?.show(relativeTo: sender.bounds, of: sender, preferredEdge: .maxY)
        }
        
        // NSTableViewDataSource
        func numberOfRows(in tableView: NSTableView) -> Int {
            return parent.options.count
        }
        
        // NSTableViewDelegate
        func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
            let cell = NSTextField()
            cell.stringValue = parent.options[row]
            cell.isEditable = false
            cell.isBordered = false
            cell.backgroundColor = .clear
            
            if parent.options[row] == "Double Click" {
                cell.textColor = .disabledControlTextColor
            }
            
            return cell
        }
        
        func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
            return parent.options[row] != "Double Click"
        }
        
        func tableViewSelectionDidChange(_ notification: Notification) {
            if let tableView = notification.object as? NSTableView {
                let row = tableView.selectedRow
                if row >= 0 && row < parent.options.count && !parent.options[row].contains("locked") {
                    parent.selectedPattern = parent.options[row]
                    popover?.close()
                }
            }
        }
    }
} 