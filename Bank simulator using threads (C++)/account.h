#ifndef ACCOUNT_H
#define ACCOUNT_H

#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <iostream>
#include <pthread.h>
#include <iomanip>
#include "mutex.h"

enum LockState {LOCKED, UNLOCKED};

using namespace std;

class Account
{
private:
    int accountID;
    int password;
    int balance;
    pthread_mutex_t *accountReadLock;
    pthread_mutex_t *accountWriteLock;
    size_t readCount;
public:
    // constractor and destractor
    Account(int accountID, int password, int balance);
    ~Account();  
    // getters
    int getAccountID() const;
    int getPassword() const;
    int getBalance() const;
    size_t getReadCount() const;
    // setters
    void setDepositBalance(int amount);
    void setWithdrawBalance(int amount);
    void setAccountReadLock(LockState newLockState);
    void setAccountWriteLock(LockState newLockState);
    void incReadCount();
    void decReadCount();
    //other function
    void printAccount();
};

#endif
