// this is PatternTabView.swift
// /Users/hadialmusawi/Desktop/FeatherAutoClicker/FeatherAutoClicker/UI/Views/Tabs/PatternTabView.swift

import SwiftUI
import AppKit

struct PatternTabView: View {
    @ObservedObject var state: ClickerState
    @State private var isRecognizing = false
    
    var body: some View {
        VStack(spacing: 20) {
            // Recognition Button
            Button(action: {
                isRecognizing.toggle()
                if isRecognizing {
                    SimpleBridge.shared().startRecognizingClick()
                } else {
                    SimpleBridge.shared().stopRecognizingClick()
                }
            }) {
                Text(isRecognizing ? "Stop Recognition " : "Start Recognition")
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .frame(width: 140, height: 26)
                    .background(isRecognizing ? Color.red.opacity(0.8) : Color.blue.opacity(0.8))
                    .foregroundColor(.white)
                    .cornerRadius(6)
            }
            .buttonStyle(PlainButtonStyle())
            
            Text("Coming Soon!")
                .font(.system(size: 24, weight: .semibold))
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 100)
            
            Text("Create custom click patterns\nand sequences")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)
        }
    }
}
