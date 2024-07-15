#ifndef GLOBALS_H
#define GLOBALS_H

/*-----------------------------------------------------------------------------
globals.h exists to declare globals needed for both atm.cpp and bank.cpp.
-----------------------------------------------------------------------------*/

#include <cstdlib>
#include <cstring>
#include <vector>
#include <fstream>
#include <pthread.h>
#include "account.h"

extern vector<Account*> bankAccounts;    // The Bank's Accounts
extern ofstream logFile;                 // log.txt
extern pthread_mutex_t *logLock;         // Lock for log.txt
extern pthread_mutex_t *printScreenLock; // Lock for STDOUT and STDERR
// read-write locks for Data Structure
extern pthread_mutex_t *bankAccountsReadLock;
extern pthread_mutex_t *bankAccountsWriteLock;
extern size_t bankAccountsReadCount;

// Define a struct to hold the arguments needed by handleATM
struct HandleATMArgs {
    string atmInputFilename;
    size_t atmID;
};

#endif
