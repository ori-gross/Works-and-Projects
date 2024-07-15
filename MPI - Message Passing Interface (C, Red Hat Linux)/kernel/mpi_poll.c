#include <linux/kernel.h>
#include <linux/module.h>
#include <linux/init.h>
#include <linux/slab.h>
#include <linux/list.h>

#include <asm/current.h>
#include <asm/uaccess.h>

#include <linux/sched.h>
#include <linux/mpi.h>
#include <linux/mpi_poll_entry.h>

#include <linux/time.h> // for using HZ
#include <linux/wait.h> // for wait

extern wait_queue_head_t mpi_wait_queue;

int sys_mpi_poll(struct mpi_poll_entry *poll_pids, int npids, int timeout) {
    struct task_struct *task = current;
    struct mpi_poll_entry *kernel_poll_pids;
    struct list_head *pos1, *tmp1;
    struct list_head *pos2, *tmp2;
    message_t *msg;
    int i, retval, num_of_incoming_entries = 0;

    if (!task->mpi_registered) // The current process isn't registered for MPI.
        return -EPERM;
    if (npids < 1 || timeout < 0) // npids<1 or timeout<0.
        return -EINVAL;
    kernel_poll_pids = kmalloc(npids*sizeof(struct mpi_poll_entry), GFP_KERNEL);
    if (!kernel_poll_pids) // Error allocating memory.
        return -ENOMEM;
    retval = copy_from_user(kernel_poll_pids, poll_pids, npids*sizeof(struct mpi_poll_entry));
    if (retval) { // Error copying poll_pids from user space.
        kfree(kernel_poll_pids);
        return -EFAULT;
    }

    // Initializing kernel_poll_pids incomings
    for (i = 0; i < npids; i++) {
        kernel_poll_pids[i].incoming = 0;
    }

    // Check all entries of poll_pids array.
    list_for_each_safe(pos1, tmp1, &task->message_queue) {
        msg = list_entry(pos1, struct message, list);
        for (i = 0; i < npids; i++) {
            if (!kernel_poll_pids[i].incoming && kernel_poll_pids[i].pid == msg->sender_pid) {
                kernel_poll_pids[i].incoming = 1;
                num_of_incoming_entries++;
            }
        }
    }

    // If none of the given PIDs has an incoming message, go to sleep.
    if (num_of_incoming_entries == 0) {
        wait_queue_t wait;
        init_waitqueue_entry(&wait, task);
        add_wait_queue(&task->mpi_wait_queue, &wait);
        
        set_current_state(TASK_INTERRUPTIBLE);
        schedule_timeout(timeout * HZ);

        __set_current_state(TASK_RUNNING);
        remove_wait_queue(&task->mpi_wait_queue, &wait);
        
        // Check all entries of poll_pids array (after message arrives or until timeout expires).
        list_for_each_safe(pos2, tmp2, &task->message_queue) {
            msg = list_entry(pos2, struct message, list);
            for (i = 0; i < npids; i++) {
                if (!kernel_poll_pids[i].incoming && kernel_poll_pids[i].pid == msg->sender_pid) {
                    kernel_poll_pids[i].incoming = 1;
                    num_of_incoming_entries++;
                }
            }
        }
        if (num_of_incoming_entries == 0) { // No message arrived before timeout expired.
            kfree(kernel_poll_pids);
            return -ETIMEDOUT;
        }
    }

    // Report all available messages.
    retval = copy_to_user(poll_pids, kernel_poll_pids, npids*sizeof(struct mpi_poll_entry));
    kfree(kernel_poll_pids);
    if (retval) // Error copying poll_pids to user space.
        return -EFAULT;

    return num_of_incoming_entries;
}
