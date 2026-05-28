import socket
import struct

UDP_IP = "127.0.0.1"
UDP_PORT = 5005

def main():
  sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
  sock.bind((UDP_IP, UDP_PORT))

  while True:
    data, addr = sock.recvfrom(4)
    joystick_x, joystick_y, button_data = struct.unpack('!bbH', data)
    print(f"Received data from {addr}: Joystick X={joystick_x}, Joystick Y={joystick_y}, Button Data={button_data}")


if __name__ == "__main__":
  main()