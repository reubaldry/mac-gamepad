import argparse
import socket
import struct
import threading
from KeyboardMouseAdapter import KeyboardMouseAdapter
import time

UDP_IP = "0.0.0.0"
UDP_PORT = 5005
VERBOSE = False

def main():
    parser = argparse.ArgumentParser(
                    prog='network_receiver.py',
                    description='Handles incoming traffic from the gamepad client and translates it into keyboard/mouse actions.')
    
    parser.add_argument('--ip', type=str, default=UDP_IP)
    parser.add_argument('--port', type=int, default=UDP_PORT)
    parser.add_argument('-v', '--verbose', action='store_true')

    args = parser.parse_args()

    if args.verbose:
        global VERBOSE
        VERBOSE = True

    start_server(args.ip, args.port)

def udp_listener(sock, controller, stop_event):
  while not stop_event.is_set():
        try:
            data, addr = sock.recvfrom(6)
            jx, jy, mx, my, buttons = struct.unpack('!bbbbH', data)
            if VERBOSE:
                print(f"Received data from {addr}: Joystick X={jx}, Joystick Y={jy}, Mouse X={mx}, Mouse Y={my}, Button Data={buttons}")
            
            if bool(buttons & (1 << 15)):
                handle_disconnection(controller)
                continue
            else:
              controller.set_button_state(buttons)
              controller.set_mouse_target(mx, my)
              controller.set_joystick(jx, jy)
        except socket.timeout:
            continue
        except Exception as e:
            print(f"Network error: {e}")
  
  print("UDP listener thread exiting.")

def start_server(ip, port):
    controller = KeyboardMouseAdapter()
    stop_event = threading.Event()
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    sock.settimeout(0.5)
    sock.bind((ip, port))
    if VERBOSE:
        print(f"Server listening on {ip}:{port}...\nPress Ctrl+C to stop.")
        print("Verbose mode enabled.")
    else:
        print(f"Server listening on {ip}:{port}...\nPress Ctrl+C to stop.")
    
    listener_thread = threading.Thread(target=udp_listener, name="udp_listener", args=(sock, controller, stop_event), daemon=True)
    listener_thread.start()
    
    try:
        while True:
            controller.tick()
            time.sleep(1.0 / 120.0) 
            
    except KeyboardInterrupt:
        print("\nServer shutting down.")
        stop_event.set()
        listener_thread.join()
    finally:
        sock.close()
        print("Server stopped.")

def handle_disconnection(controller):
    print("Client disconnected. Resetting controller state.")
    controller.set_button_state(0)
    controller.set_mouse_target(0, 0)
    controller.set_joystick(0, 0)
    # Implement any necessary cleanup or state reset here



if __name__ == "__main__":
  main()