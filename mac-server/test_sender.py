import socket
import struct
import time

TARGET_IP = "127.0.0.1"
TARGET_PORT = 5005

def main():
  sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
  print(f"Sending mock controller packets to {TARGET_IP}:{TARGET_PORT}...")

  try:
    while True:
        mock_x = 50
        mock_y = -100
        mock_buttons = 4

        payload = struct.pack('!bbH', mock_x, mock_y, mock_buttons)

        sock.sendto(payload, (TARGET_IP, TARGET_PORT))
        
        print(f"Sent state: X={mock_x}, Y={mock_y}, Buttons={mock_buttons}")
        
        time.sleep(0.1)

  except KeyboardInterrupt:
      print("\nTest client stopped.")
  finally:
      sock.close()

if __name__ == "__main__":
  main()