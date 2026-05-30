//
//  GamepadController.swift
//  MacGamepad
//
//  Created by Reuben Baldry on 2026/05/29.
//
import Foundation
import GameController
import Observation
import QuartzCore // Required for CADisplayLink

// Handles button states. Can handle 16 buttons.
struct GamepadButtons: OptionSet {
    let rawValue: UInt16

    static let buttonA = GamepadButtons(rawValue: 1 << 0) // 0000 0001
    static let buttonB = GamepadButtons(rawValue: 1 << 1) // 0000 0010
    static let buttonX = GamepadButtons(rawValue: 1 << 2) // 0000 0100
    static let buttonY = GamepadButtons(rawValue: 1 << 3) // 0000 1000
    static let bumperL = GamepadButtons(rawValue: 1 << 4) // 0001 0000
    static let bumperR = GamepadButtons(rawValue: 1 << 5) // 0010 0000
}

@Observable
class GamepadController {
    var isConnected: Bool = false
    private var virtualController: GCVirtualController?
    
    // State variables
    private var currentX: Int8 = 0
    private var currentY: Int8 = 0
    private var mouseDeltaX: Int8 = 0
    private var mouseDeltaY: Int8 = 0
    public var activeButtons: GamepadButtons = []
    
    private var displayLink: CADisplayLink?
    
    init() {
        NotificationCenter.default.addObserver(
            forName: .GCControllerDidConnect,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            guard let controller = notification.object as? GCController,
                  let gamepad = controller.extendedGamepad else { return }
            self?.attachListeners(to: gamepad)
        }
    }
    
    func toggleConnection() {
        if isConnected {
            virtualController?.disconnect()
            stopTickLoop()
            isConnected = false
        } else {
            let config = GCVirtualController.Configuration()
            config.elements = [GCInputLeftThumbstick]
            
            virtualController = GCVirtualController(configuration: config)
            virtualController?.connect()
            
            startTickLoop()
            isConnected = true
        }
    }
    
    // --- 1. THE HARDWARE CLOCK ---
    private func startTickLoop() {
        displayLink = CADisplayLink(target: self, selector: #selector(tick))
        displayLink?.add(to: .main, forMode: .common)
    }
    
    private func stopTickLoop() {
        displayLink?.invalidate()
        displayLink = nil
    }
    
    @objc private func tick() {
        send_controller_state(currentX, currentY, mouseDeltaX, mouseDeltaY, activeButtons.rawValue)
        
        // Reset the mouse delta after the frame has been sent
        mouseDeltaX = 0
        mouseDeltaY = 0
    }
    
    // --- 2. THE UI HANDLERS ---
    func setButtonState(_ button: GamepadButtons, isPressed: Bool) {
        if isPressed {
            self.activeButtons.insert(button)
        } else {
            self.activeButtons.remove(button)
        }
    }
    
    func updateMouse(deltaX: Int8, deltaY: Int8) {
        self.mouseDeltaX = deltaX
        self.mouseDeltaY = deltaY
    }
    
    private func attachListeners(to gamepad: GCExtendedGamepad) {
        gamepad.leftThumbstick.valueChangedHandler = { [weak self] _, x, y in
            // Just update memory.
            self?.currentX = Int8(x * 127)
            self?.currentY = Int8(y * -127)
        }
    }
}
