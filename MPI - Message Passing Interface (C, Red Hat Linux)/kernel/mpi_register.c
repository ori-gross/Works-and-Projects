#include <linux/kernel.h>
#include <linux/module.h>
#include <linux/init.h>
#include <linux/slab.h>
#include <linux/list.h>

#include <asm/current.h>
#include <asm/uaccess.h>

#include <linux/sched.h>

int sys_mpi_register(void) {    
    struct task_struct *task = current;
    if (task->mpi_registered) {
        return 0;
    }
    INIT_LIST_HEAD(&task->message_queue); // Initialize the message queue
    task->mpi_registered = 1;
    init_waitqueue_head(&task->mpi_wait_queue); // Initialize the wait queue
    return 0;
}
