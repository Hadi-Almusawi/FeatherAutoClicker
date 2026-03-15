// this is ContentView.swift
// /Users/hadialmusawi/Desktop/FeatherAutoClicker/FeatherAutoClicker/UI/Views/ContentView.swift

import SwiftUI

// Add at the top level of the file
class ThemeSettings: ObservableObject {
    @Published var isDarkMode: Bool = true
}

struct ContentView: View {
    @EnvironmentObject private var state: ClickerState
    @StateObject private var themeSettings = ThemeSettings()
    @State private var selectedButton: String = "Basic"
    let sliderColor = Color.blue
    
    var body: some View {
        ZStack {
            // Full background container - No animation
            Color(themeSettings.isDarkMode ? 
                NSColor(red: 0.15, green: 0.15, blue: 0.15, alpha: 1.0) : 
                NSColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1.0))
                .edgesIgnoringSafeArea(.all)
                .padding(.top, 21)
                .animation(nil, value: themeSettings.isDarkMode) // Explicitly disable animation
            
            // Main content
            VStack(spacing: 20) {
                // Tab Buttons under header
                HStack(spacing: 0) {
                    Button(action: {
                        selectedButton = "Basic"
                    }) {
                        Text("Basic")
                            .frame(width: 70, height: 24) // Decreased width and height
                            .background(
                                RoundedRectangle(cornerRadius: 3)
                                    .fill(selectedButton == "Basic" ? sliderColor : Color.gray.opacity(0.2))
                            )
                            .foregroundColor(selectedButton == "Basic" ? .white : .primary)
                            .overlay(
                                Rectangle()
                                    .frame(width: 1)
                                    .foregroundColor(Color.gray.opacity(selectedButton == "Basic" || selectedButton == "Pattern" ? 0.1 : 0.3))
                                    .padding(.vertical, 4),
                                alignment: .trailing
                            )
                    }

                    Button(action: {
                        selectedButton = "Pattern"
                    }) {
                        Text("Pattern")
                            .frame(width: 70, height: 24) // Decreased width and height
                            .background(
                                RoundedRectangle(cornerRadius: 3)
                                    .fill(selectedButton == "Pattern" ? sliderColor : Color.gray.opacity(0.2))
                            )
                            .foregroundColor(selectedButton == "Pattern" ? .white : .primary)
                            .overlay(
                                Rectangle()
                                    .frame(width: 1)
                                    .foregroundColor(Color.gray.opacity(selectedButton == "Pattern" || selectedButton == "Record" ? 0.1 : 0.3))
                                    .padding(.vertical, 4),
                                alignment: .trailing
                            )
                    }

                    Button(action: {
                        selectedButton = "Record"
                    }) {
                        Text("Record")
                            .frame(width: 70, height: 24) // Decreased width and height
                            .background(
                                RoundedRectangle(cornerRadius: 3)
                                    .fill(selectedButton == "Record" ? sliderColor : Color.gray.opacity(0.2))
                            )
                            .foregroundColor(selectedButton == "Record" ? .white : .primary)
                    }
                }
                .cornerRadius(4)
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(Color.gray.opacity(0.5), lineWidth: 1.5)
                )
                .buttonStyle(PlainButtonStyle())
                .font(.system(size: 13, weight: .medium)) // Increased font size
                .padding(.top, 30)  // Changed from 15 to 25 to move tabs even lower
                
                // Content based on selected tab
                if selectedButton == "Basic" {
                    BasicTabView(state: state)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if selectedButton == "Pattern" {
                    PatternTabView(state: state)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    RecordTabView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            
            // Version info overlay at bottom
            VStack {
                Spacer()
                VStack(spacing: 4) {
                    Divider()
                        .frame(width: 517)  // Changed from 520 to 517
                        .background(Color.gray.opacity(0.3))
                    
                    ZStack {  // Use ZStack to layer elements
                        // Full width HStack for Version
                        HStack {
                            Spacer()
                            Text("Version 0.1")
                                .font(.system(size: 10))
                                .foregroundColor(.secondary)
                                .padding(.trailing, 16)
                        }
                        
                        // Centered Discord text
                        Text("Discord")
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, 4)
                }
            }
            .zIndex(0)
        }
        .animation(.easeInOut(duration: 0.2), value: themeSettings.isDarkMode)
        .preferredColorScheme(themeSettings.isDarkMode ? .dark : .light)
        .overlay(
            // Header
            ZStack {
                Color(.windowBackgroundColor)
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                    )
                    .edgesIgnoringSafeArea(.top)
                
                ZStack {
                    // Title centered absolutely
                    HStack(spacing: 4) {
                        Text("FEATHER")
                            .font(.system(size: 18, weight: .heavy, design: .rounded))
                            .foregroundColor(.primary)
                            .animation(nil)
                        
                        Text("CLICKER")
                            .font(.system(size: 18, weight: .regular, design: .rounded))
                            .foregroundColor(.secondary)
                            .animation(nil)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    
                    // Theme toggle button positioned absolutely on the right
                    HStack {
                        Spacer()
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.1)) {
                                themeSettings.isDarkMode.toggle()
                            }
                        }) {
                            Image(systemName: themeSettings.isDarkMode ? "sun.max.fill" : "moon.fill")
                                .font(.system(size: 14))
                                .foregroundColor(.primary)
                                .rotationEffect(.degrees(themeSettings.isDarkMode ? 0 : -90))
                                .animation(.easeInOut(duration: 0.2), value: themeSettings.isDarkMode)
                                .frame(width: 14, height: 14)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .frame(width: 40)
                        .padding(.trailing, 16)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .offset(y: -10.7)
            }
            .frame(height: 21)
            , alignment: .top
        )
        .environmentObject(themeSettings)
        .frame(width: 550, height: 440)
    }
}
