//
//  ContentView.swift
//  MacGamepad
//
//  Created by Reuben Baldry on 2026/05/28.
//

import SwiftUI

struct ContentView: View {
    @State private var manager = GamepadController()
    
    @GestureState private var isLooking = false
    @GestureState private var isFiring = false
    
    @State private var aimDragTranslation: CGSize = .zero
    @State private var fireDragTranslation: CGSize = .zero
    
    @State private var aimState = false
    
    var body: some View {
        ZStack {
            // Background layer
            Color.black.edgesIgnoringSafeArea(.all)
            
            // THE AIM-ONLY TRACKPAD (Background) ---
            HStack(spacing: 0) {
                Color.clear
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                Color.white.opacity(0.001)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .allowsHitTesting(manager.isConnected)
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .updating($isLooking) { _, state, _ in state = true }
                            .onChanged { value in
                                let deltaX = value.translation.width - aimDragTranslation.width
                                let deltaY = value.translation.height - aimDragTranslation.height
                                aimDragTranslation = value.translation
                                
                                manager.updateMouse(
                                    deltaX: Int8(max(min(deltaX, 127), -128)),
                                    deltaY: Int8(max(min(deltaY, 127), -128))
                                )
                            }
                    )
                    // The Failsafe Cleanup
                    .onChange(of: isLooking) { oldValue, newValue in
                        if !newValue {
                            aimDragTranslation = .zero
                            manager.updateMouse(deltaX: 0, deltaY: 0)
                        }
                    }
            }
            
            // Fire button
            if manager.isConnected {
                HStack {
                    Spacer()
                    
                    GameButton(label: "B", isToggle: true) {
                        pressed in manager.setButtonState(.buttonB, isPressed: pressed)
                    }.position(x: 700, y: 150)
                    
                    Circle()
                        .fill(Color.red.opacity(0.5))
                        .frame(width: 80, height: 80)
                        .padding(.trailing, 60)
                        .padding(.bottom, 60)
                        .position(x: 300, y: 300)
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .updating($isFiring) { _, state, _ in state = true }
                                .onChanged { value in
                                    let deltaX = value.translation.width - fireDragTranslation.width
                                    let deltaY = value.translation.height - fireDragTranslation.height
                                    fireDragTranslation = value.translation
                                    
                                    // Turn the button on, and push the mouse coordinates
                                    manager.setButtonState(.buttonA, isPressed: true)
                                    manager.updateMouse(
                                        deltaX: Int8(max(min(deltaX, 127), -128)),
                                        deltaY: Int8(max(min(deltaY, 127), -128))
                                    )
                                }
                        )
                        // The Failsafe Cleanup
                        .onChange(of: isFiring) { oldValue, newValue in
                            if !newValue {
                                fireDragTranslation = .zero
                                manager.updateMouse(deltaX: 0, deltaY: 0)
                                manager.setButtonState(.buttonA, isPressed: false)
                            }
                        }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
            }
            
            // CONNECT BUTTON ---
            VStack {
                Button(manager.isConnected ? "Disconnect" : "Connect Gamepad") {
                    manager.toggleConnection()
                }
                .buttonStyle(.borderedProminent)
                .tint(manager.isConnected ? .red : .blue)
                .controlSize(.large)
            }
        }
    }
}

#Preview {
    ContentView()
}
