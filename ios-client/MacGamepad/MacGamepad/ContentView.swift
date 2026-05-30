//
//  ContentView.swift
//  MacGamepad
//
//  Created by Reuben Baldry on 2026/05/28.
//

import SwiftUI

struct ContentView: View {
    @State private var manager = GamepadController()
    @State private var lastDragTranslation: CGSize = .zero
    
    var body: some View {
        ZStack {
            // Background layer
            Color.black.edgesIgnoringSafeArea(.all)
            
            // The Trackpad Layer (Bypasses UIScreen.main entirely)
            HStack(spacing: 0) {
                // Left half of the screen remains empty space
                Spacer()
                
                // Right half becomes the flexible touch target
                Color.white.opacity(0.001)
                    .frame(maxWidth: .infinity, maxHeight: .infinity) // Automatically takes exactly 50% width
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                // Calculate velocity delta between frames
                                let deltaX = value.translation.width - lastDragTranslation.width
                                let deltaY = value.translation.height - lastDragTranslation.height
                                
                                lastDragTranslation = value.translation
                                
                                // Clean boundary clamping for our C signed chars
                                let clampedX = Int8(max(min(deltaX, 127), -128))
                                let clampedY = Int8(max(min(deltaY, 127), -128))
                                
                                manager.updateMouse(deltaX: clampedX, deltaY: clampedY)
                            }
                            .onEnded { _ in
                                lastDragTranslation = .zero
                                manager.updateMouse(deltaX: 0, deltaY: 0)
                            }
                    )
            }
            
            // The UI Layer (Floating on top)
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
