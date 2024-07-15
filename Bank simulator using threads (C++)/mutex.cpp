#include "mutex.h"

/*-----------------------------------------------------------------------------
mutex.h and mutex.cpp exist to reduce perrors and exits(-1) in the code.
-----------------------------------------------------------------------------*/

void mutexInit(pthread_mutex_t *lock) {
    int retval = pthread_mutex_init(lock, NULL);
    if (retval) {
        perror("Bank error: pthread_mutex_init failed");
        exit(-1);
    }
}

void mutexLock(pthread_mutex_t *lock) {
    int retval = pthread_mutex_lock(lock);
    if (retval) {
        perror("Bank error: pthread_mutex_lock failed");
        exit(-1);
    }
}

void mutexUnlock(pthread_mutex_t *lock) {
    int retval = pthread_mutex_unlock(lock);
    if (retval) {
        perror("Bank error: pthread_mutex_unlock failed");
        exit(-1);
    }
}

void mutexDestroy(pthread_mutex_t *lock) {
    int retval = pthread_mutex_destroy(lock);
    if (retval) {
        perror("Bank error: pthread_mutex_destroy failed");
        exit(-1);
    }
}
