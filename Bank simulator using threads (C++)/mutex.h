#ifndef MUTEX_H
#define MUTEX_H

/*-----------------------------------------------------------------------------
mutex.h and mutex.cpp exist to reduce perrors and exits(-1) in the code.
-----------------------------------------------------------------------------*/

#include <cstdio>
#include <cstdlib>
#include <pthread.h>

void mutexInit(pthread_mutex_t *lock);
void mutexLock(pthread_mutex_t *lock);
void mutexUnlock(pthread_mutex_t *lock);
void mutexDestroy(pthread_mutex_t *lock);

#endif
