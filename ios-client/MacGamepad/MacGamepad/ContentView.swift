//
//  ContentView.swift
//  MacGamepad
//
//  Created by Reuben Baldry on 2026/05/28.
//

import SwiftUI

struct ContentView: View {
    @State private var manager = GamepadController()
    
    // 1. The failsafe states. These guarantee they return to 'false' if the OS drops the touch.
    @GestureState private var isAiming = false
    @GestureState private var isFiring = false
    
    @State private var aimDragTranslation: CGSize = .zero
    @State private var fireDragTranslation: CGSize = .zero
    
    var body: some View {
        ZStack {
            // Background layer
            Color.black.edgesIgnoringSafeArea(.all)
            
            // --- 1. THE AIM-ONLY TRACKPAD (Background) ---
            HStack(spacing: 0) {
                Color.clear
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                Color.white.opacity(0.001)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .allowsHitTesting(manager.isConnected)
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .updating($isAiming) { _, state, _ in state = true }
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
                    .onChange(of: isAiming) { oldValue, newValue in
                        if !newValue {
                            aimDragTranslation = .zero
                            manager.updateMouse(deltaX: 0, deltaY: 0)
                        }
                    }
            }
            
            // --- 2. THE FIRE + AIM BUTTON (Foreground) ---
            if manager.isConnected {
                HStack {
                    Spacer()
                    
                    Circle()
                        .fill(Color.red.opacity(0.5))
                        .frame(width: 80, height: 80)
                        .padding(.trailing, 60)
                        .padding(.bottom, 60)
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
            
            // --- 3. CONNECT BUTTON ---
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
