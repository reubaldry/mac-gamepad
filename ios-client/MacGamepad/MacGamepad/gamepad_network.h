//
//  gamepad_network.h
//  MacGamepad
//
//  Created by Reuben Baldry on 2026/05/28.
//

#ifndef gamepad_network_h
#define gamepad_network_h

#include <stdio.h>
#include <stdint.h>
#include <sys/socket.h>
#include <arpa/inet.h>
#include <stdlib.h>
#include <unistd.h>
#include <netdb.h>
#include <string.h>

#define SERVERPORT "5005"
#define SERVERIP "192.168.101.234"

void init_socket(void);
int send_controller_state(int8_t joystick_x, int8_t joystick_y, int8_t mouse_x, int8_t mouse_y, uint16_t button);

#endif /* gamepad_network_h */
