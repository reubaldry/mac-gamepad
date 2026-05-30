from pynput.keyboard import Controller as KeyboardController, Key
from pynput.mouse import Button, Controller as MouseController

class KeyboardMouseAdapter:
    def __init__(self):
        self.keyboard = KeyboardController()
        self.mouse = MouseController()
        
        # Mouse movement
        self.target_mx = 0.0
        self.target_my = 0.0
        
        self.vel_x = 0.0
        self.vel_y = 0.0
        
        self.remainder_x = 0.0
        self.remainder_y = 0.0
        
        self.alpha = 0.3       
        self.sensitivity = 2.0 
        
        # Button state
        self.active_keys = set()
        self.button_state = 0

        # Joystick state
        self.joystick_x = 0
        self.joystick_y = 0

        self.deadzone = 40

    def set_mouse_target(self, delta_x: int, delta_y: int):
        self.target_mx = float(delta_x) * self.sensitivity
        self.target_my = float(delta_y) * self.sensitivity
        
    def set_button_state(self, button_data: int):
        is_a_pressed = bool(button_data & (1 << 0))
        is_b_pressed = bool(button_data & (1 << 1))

        if is_a_pressed:
            self.mouse.press(Button.left)
        else:
            self.mouse.release(Button.left)

        if is_b_pressed:
            self.mouse.press(Button.right)
        else:
            self.mouse.release(Button.right)


    def set_joystick(self, jx: int, jy: int):
        self.joystick_x = jx
        self.joystick_y = jy

    def joystick_to_key(self, jx: int, jy: int):
        if jy > self.deadzone:
            self.keyboard.press('s')
        else:
            self.keyboard.release('s')

        if jy < -self.deadzone:
            self.keyboard.press('w')
        else:
            self.keyboard.release('w')

        if jx > self.deadzone:
            self.keyboard.press('d')
        else:
            self.keyboard.release('d')

        if jx < -self.deadzone:
            self.keyboard.press('a')
        else:
            self.keyboard.release('a')

    def tick(self):
        # 1. EMA Filter
        self.vel_x = (self.alpha * self.target_mx) + ((1.0 - self.alpha) * self.vel_x)
        self.vel_y = (self.alpha * self.target_my) + ((1.0 - self.alpha) * self.vel_y)
        
        # 2. Force decay if input stops
        if self.target_mx == 0:
            self.vel_x *= 0.5
        if self.target_my == 0:
            self.vel_y *= 0.5
            
        # 3. Add the leftover fractions from the last frame
        total_x = self.vel_x + self.remainder_x
        total_y = self.vel_y + self.remainder_y
        
        # 4. Extract the integer pixel movement
        move_x = int(total_x)
        move_y = int(total_y)
        
        # 5. Save the remaining decimals for the next frame
        self.remainder_x = total_x - move_x
        self.remainder_y = total_y - move_y
        
        # 6. Execute!
        if move_x != 0 or move_y != 0:
            self.mouse.move(move_x, move_y)

        

        self.joystick_to_key(self.joystick_x, self.joystick_y)