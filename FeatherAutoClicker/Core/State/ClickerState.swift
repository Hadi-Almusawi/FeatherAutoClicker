// This is ClickerState.swift
// /Users/hadialmusawi/Desktop/FeatherAutoClicker/FeatherAutoClicker/Core/State/ClickerState.swift
import Foundation
import SwiftUI
import Cocoa
import AppKit

class ClickerState: ObservableObject {
    private let clicker = AutoClickerBridge.shared()
    
    @Published var isActive = false {
        didSet {
            if isActive {
                clicker.startClicking(Float(speed), isRight: isRightClick)
            } else {
                clicker.stopClicking()
            }
        }
    }
    
    @Published var speed: Double = 1.0 {
        didSet {
            if isActive {
                clicker.startClicking(Float(speed), isRight: isRightClick)
            }
        }
    }
    
    @Published var isSpiked: Bool = false {
        didSet {
            clicker.setRandomization(isSpiked)
        }
    }
    
    @Published var isLeftClick: Bool = true {
        didSet {
            if isActive {
                clicker.startClicking(Float(speed), isRight: false)
            }
        }
    }
    
    @Published var isRightClick: Bool = false {
        didSet {
            if isActive {
                clicker.startClicking(Float(speed), isRight: true)
            }
        }
    }
    
    @Published var clickCount: Int = 0
    
    func toggleClicking() {
        isActive.toggle()
    }
}