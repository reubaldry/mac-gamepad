from pynput.mouse import Button, Controller

mouse = Controller()

def move_mouse(x, y):
  mouse.move(x, y)

def handle_input(jx, jy, mx, my, button_data):
  move_mouse(mx, my)