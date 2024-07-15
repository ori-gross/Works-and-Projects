#ifndef _LINUX_MPI_H
#define _LINUX_MPI_H

#include <linux/list.h>

struct message {
    struct list_head list; // Linked list structure
    pid_t sender_pid;      // Sender's pid
    ssize_t size;          // Size of the message
    char *content;         // Pointer to the message content
} typedef message_t;

#endif /* _LINUX_MPI_H */
