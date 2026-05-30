//
//  ContentView.swift
//  MacGamepad
//
//  Created by Reuben Baldry on 2026/05/28.
//

import SwiftUI

struct ContentView: View {
    @State private var manager = GamepadController()
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
                            .onChanged { value in
                                processMovement(value: value, lastTranslation: &aimDragTranslation, isFiring: false)
                            }
                            .onEnded { _ in
                                aimDragTranslation = .zero
                                manager.updateMouse(deltaX: 0, deltaY: 0, trackpadPressed: false)
                            }
                    )
            }
            
            // --- 2. THE UI BUTTON LAYER (Foreground) ---
            if manager.isConnected {
                HStack {
                    Spacer() // Push to the right
                    
                    // The "Fire + Aim" Button
                    Circle()
                        .fill(Color.red.opacity(0.5)) // Semi-transparent so you can see behind it
                        .frame(width: 80, height: 80)
                        .padding(.trailing, 60)
                        .padding(.bottom, 60)
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { value in
                                    // Pass true for isFiring
                                    processMovement(value: value, lastTranslation: &fireDragTranslation, isFiring: true)
                                }
                                .onEnded { _ in
                                    fireDragTranslation = .zero
                                    manager.updateMouse(deltaX: 0, deltaY: 0, trackpadPressed: false)
                                }
                        )
                }
                // Align this layer to the bottom right corner
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
            }
            
            // UI layer
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
    
    // Processes math for mouse movement
    private func processMovement(value: DragGesture.Value, lastTranslation: inout CGSize, isFiring: Bool) {
        let deltaX = value.translation.width - lastTranslation.width
        let deltaY = value.translation.height - lastTranslation.height
        
        lastTranslation = value.translation
        
        let clampedX = Int8(max(min(deltaX, 127), -128))
        let clampedY = Int8(max(min(deltaY, 127), -128))
            
        if isFiring {
            manager.activeButtons.insert(.buttonA)
        } else {
            manager.activeButtons.remove(.buttonA)
        }
        
        manager.updateMouse(deltaX: clampedX, deltaY: clampedY)
    }
}

#Preview {
    ContentView()
}
