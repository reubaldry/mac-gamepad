//
//  gamepad_network.c
//  MacGamepad
//
//  Created by Reuben Baldry on 2026/05/28.
//

#include "gamepad_network.h"

static int sockfd = -1;
static struct sockaddr_storage server_addr;
static socklen_t server_addr_len;
static int is_initialized = 0;

void init_socket(void) {
    if (sockfd != -1) {
        close(sockfd);
        sockfd = -1;
    }
    
    struct addrinfo hints, *servinfo, *p;
    int rv;
    
    memset(&hints, 0, sizeof hints);
    hints.ai_family = AF_INET;
    hints.ai_socktype = SOCK_DGRAM;
    
    if ((rv = getaddrinfo(SERVERIP, SERVERPORT, &hints, &servinfo)) != 0) {
        fprintf(stderr, "Error with getaddrinfo: %s\n", gai_strerror(rv));
        return;
    }
    
    for (p = servinfo; p != NULL; p = p->ai_next) {
        if ((sockfd = socket(p->ai_family, p->ai_socktype, p->ai_protocol)) == -1) {
            continue;
        }
        
        memcpy(&server_addr, p->ai_addr, p->ai_addrlen);
        server_addr_len = p->ai_addrlen;
        break;
    }
    
    if (p == NULL) {
        fprintf(stderr, "Failed to create socket\n");
    } else {
        is_initialized = 1;
    }
    
    freeaddrinfo(servinfo);
}

int send_controller_state(int8_t joystick_x, int8_t joystick_y, int8_t mouse_x, int8_t mouse_y, uint16_t button) {
    if (!is_initialized || sockfd == -1) {
        init_socket();
        if (sockfd == -1) return EXIT_FAILURE;
    }
    
    int numbytes;
    
    uint8_t raw_packet[6];
    raw_packet[0] = (uint8_t)joystick_x;
    raw_packet[1] = (uint8_t)joystick_y;
    raw_packet[2] = (uint8_t)mouse_x;
    raw_packet[3] = (uint8_t)mouse_y;
    raw_packet[4] = (uint8_t)((button >> 8) & 0xFF);
    raw_packet[5] = (uint8_t)(button & 0xFF);
    
    if ((numbytes = sendto(sockfd, raw_packet, 6, 0, (struct sockaddr *)&server_addr, server_addr_len)) == -1) {
        exit(1);
    }
    
    if (numbytes == -1) {
//        // If the OS buffer is just temporarily full, ignore it.
//        // The next frame will arrive in 8 milliseconds anyway.
//        if (errno == ENOBUFS || errno == EAGAIN || errno == EWOULDBLOCK) {
//            return EXIT_SUCCESS;
//        }
        
        close(sockfd);
        sockfd = -1;
        is_initialized = 0;
        
        return EXIT_FAILURE;
    }
    
    printf("Client: sent %d bytes to %s\n", numbytes, SERVERIP);
    
    return EXIT_SUCCESS;
}
