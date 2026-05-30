# mac-gamepad
A solution for using your iOS device as a controller for mac.

## Overview
This project is intended to allow for an iPhone to be used as a virtual controller for a Mac.
Data is sent from the client to the server over a local network, and is then mapped to keyboard and mouse
inputs on the Mac.

## Roadmap
- [x] Basic controller layout
- [x] Basic movement and mouse input
- [x] Robust network transfers
- [ ] Customisable button input
- [ ] Customisable controller layout
- [ ] Server GUI
- [ ] Scan for local devices from client
- [ ] Actual controller emulation (not kbm)

## Requirements
- xCode
- Python 3.11

## Usage
1) Install python requirements with `pip install -r requirements.txt`.
2) Start the server with `python3 mac-server/network_receiver.py`.
3) Connect your iPhone to the Mac and specify your device as the target in xCode.
4) Build the iOS client.
5) Run the iOS client on your device.

