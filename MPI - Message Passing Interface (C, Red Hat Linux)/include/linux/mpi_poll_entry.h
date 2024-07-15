#ifndef _LINUX_MPI_POLL_ENTRY_H
#define _LINUX_MPI_POLL_ENTRY_H

#include <linux/list.h>

struct mpi_poll_entry {
    pid_t pid;
    char incoming;
};

#endif /* _LINUX_MPI_POLL_ENTRY_H */
