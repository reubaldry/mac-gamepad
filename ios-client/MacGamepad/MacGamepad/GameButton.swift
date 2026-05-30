//
//  GameButton.swift
//  MacGamepad
//
//  Created by Reuben Baldry on 2026/05/30.
//
import SwiftUI

struct GameButton: View {
    let label: String
    var size: CGFloat = 70
    
    var isToggle: Bool = false
    
    // Note: We completely removed xOffset and yOffset from the struct
    let onStateChange: (Bool) -> Void
    
    // 1. Upgrade to GestureState to prevent dropped touches
    @GestureState private var isPhysicalTouch = false
    
    @State private var isToggled = false
    
    var body: some View {
        Circle()
            .fill(isPhysicalTouch ? Color.white.opacity(0.8) : Color.white.opacity(0.3))
            .frame(width: size, height: size)
            
            // 2. Force the OS to strictly bind the touch target to this exact circle
            .contentShape(Circle())
            
            .overlay(
                Text(label).font(.title2.bold()).foregroundColor(isPhysicalTouch ? .black : .white)
            )
            .gesture(
                DragGesture(minimumDistance: 0)
                    .updating($isPhysicalTouch) { _, state, _ in state = true }
            )
            
            // 3. Let the GestureState safely drive the network logic
            .onChange(of: isPhysicalTouch) { oldValue, newValue in
                if isToggle {
                    // TOGGLE MODE: Only trigger the logic when the finger presses DOWN
                    if newValue == true && oldValue == false {
                        isToggled.toggle()
                        onStateChange(isToggled)
                    }
                } else {
                    // MOMENTARY MODE: Just pass the raw physical touch state
                    onStateChange(newValue)
                }
            }
    }
}
