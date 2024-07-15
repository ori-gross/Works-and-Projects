#include <linux/kernel.h>
#include <linux/module.h>
#include <linux/init.h>
#include <linux/slab.h>
#include <linux/list.h>

#include <asm/current.h>
#include <asm/uaccess.h>

#include <linux/sched.h>
#include <linux/mpi.h>

/* wait */
#include <linux/wait.h>

int sys_mpi_send(pid_t pid, char *message, ssize_t message_size) {
    struct task_struct *sender_task = current;
    struct task_struct *receiver_task = find_task_by_pid(pid);
    if (!receiver_task) // Process pid doesn't exist
        return -ESRCH;
    if (!sender_task->mpi_registered || !receiver_task->mpi_registered) // Either the sending process or pid
                                                                        // isn't registered for MPI communication
        return -EPERM;
    if (!message || message_size < 1) // message is NULL or message_size < 1
        return -EINVAL;
    message_t *new_message = kmalloc(sizeof(message_t), GFP_KERNEL);
    if (!new_message) // Failure allocationg memory
        return -ENOMEM;
    new_message->size = message_size;
    new_message->sender_pid = current->pid;
    new_message->content = kmalloc(sizeof(message_size), GFP_KERNEL);
    if (!new_message->content) { // Failure allocationg memory
        kfree(new_message);
        return -ENOMEM;
    }
    int retval = copy_from_user(new_message->content, message, message_size);
    if (retval) { // Error copying message from user space
        kfree(new_message->content);
        kfree(new_message);
        return -EFAULT;
    }

    list_add_tail(&new_message->list, &receiver_task->message_queue); // Add message to the relevant queue

    // Wake up the specific receiver's wait queue
    wake_up_interruptible(&receiver_task->mpi_wait_queue);
    
    return 0; // Success
}
