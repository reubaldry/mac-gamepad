//
//  gamepad_network.c
//  MacGamepad
//
//  Created by Reuben Baldry on 2026/05/28.
//

#include "gamepad_network.h"

int init_gamepad_socket(const char *ip_address, int port) {
    struct sockaddr_in peer_addr = {
        .sin_family = AF_INET,
        .sin_port = htons(port)
    };
    
    if (inet_pton(AF_INET, ip_address, &(peer_addr.sin_addr)) <= 0) {
        perror("IP failure");
        return EXIT_FAILURE;
    }
    
    return EXIT_SUCCESS;
}

int send_controller_state(int8_t joystick_x, int8_t joystick_y, int8_t mouse_x, int8_t mouse_y, uint16_t button) {
    int sockfd;
    
    struct addrinfo hints, *servinfo, *p;
    int rv;
    int numbytes;
    
    memset(&hints, 0, sizeof hints);
    hints.ai_family = AF_INET;
    hints.ai_socktype = SOCK_DGRAM;
    
    rv = getaddrinfo(SERVERIP, SERVERPORT, &hints, &servinfo);
    
    if (rv != 0) {
        fprintf(stderr, "Error with getaddrinfo.\n");
        return EXIT_FAILURE;
    }
    
    for (p = servinfo; p != NULL; p = p->ai_next) {
        if ((sockfd = socket(p->ai_family, p->ai_socktype, p->ai_protocol)) == -1) {
            continue;
        }
        
        break;
    }
    
    if (p == NULL) {
        fprintf(stderr, "Failed to create socket\n");
        return EXIT_FAILURE;
    }
    
    uint8_t raw_packet[6];
    raw_packet[0] = (uint8_t)joystick_x;
    raw_packet[1] = (uint8_t)joystick_y;
    raw_packet[2] = (uint8_t)mouse_x;
    raw_packet[3] = (uint8_t)mouse_y;
    raw_packet[4] = (uint8_t)((button >> 8) & 0xFF);
    raw_packet[5] = (uint8_t)(button & 0xFF);
    
    if ((numbytes = sendto(sockfd, raw_packet, 6, 0, p->ai_addr, p->ai_addrlen)) == -1) {
        exit(1);
    }
    
    freeaddrinfo(servinfo);
    
    printf("talker: sent %d bytes to %s\n", numbytes, SERVERIP);
    
    return EXIT_SUCCESS;
}
