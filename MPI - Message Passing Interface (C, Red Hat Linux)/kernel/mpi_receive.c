#include <linux/kernel.h>
#include <linux/module.h>
#include <linux/init.h>
#include <linux/slab.h>
#include <linux/list.h>

#include <asm/current.h>
#include <asm/uaccess.h>

#include <linux/sched.h>
#include <linux/mpi.h>

int sys_mpi_receive(pid_t pid, char *message, ssize_t message_size) {
    struct task_struct *task = current;
    struct list_head *pos, *tmp;
    message_t *new_message;
    ssize_t new_message_size = 0;
    int found = 0; 
    int retval;
    if (!task->mpi_registered) // The current process isn't registered for MPI communication
        return -EPERM;
    if (!message || message_size < 1) // message is NULL or message_size < 1
        return -EINVAL;    

    // Check if the current process has a message from process pid.
    list_for_each_safe(pos, tmp, &task->message_queue) {
        new_message = list_entry(pos, struct message, list);
        if (new_message->sender_pid == pid) { // There is a message from process pid.
            new_message_size = min(message_size, new_message->size);
            retval = copy_to_user(message, new_message->content, new_message_size);
            if (retval) // Error writing to user buffer
                return -EFAULT;
            list_del(pos);
            kfree(new_message->content);
            kfree(new_message);
            found = 1;
            break;
        }
    }

    if (!found) // No message found from pid
        return -EAGAIN;

    return new_message_size;
}
