#include "account.h"

Account::Account(int accountID, int password, int balance) : 
                 accountID(accountID), password(password), balance(balance), readCount(0) {
    this->accountReadLock = new pthread_mutex_t;
    mutexInit(this->accountReadLock);
    this->accountWriteLock = new pthread_mutex_t;
    mutexInit(this->accountWriteLock);
}

Account::~Account() {
    mutexDestroy(this->accountReadLock);
    delete this->accountReadLock;
    mutexDestroy(this->accountWriteLock);
    delete this->accountWriteLock;
}

int Account::getAccountID() const {
    return this->accountID;
}

int Account::getPassword() const {
    return this->password;
}

int Account::getBalance() const {
    return this->balance;
}

size_t Account::getReadCount() const {
    return this->readCount;
}

void Account::setDepositBalance(int amount) {
    this->balance += amount;
}
void Account::setWithdrawBalance(int amount) {
    this->balance -= amount;
}

void Account::setAccountReadLock(LockState newLockState) {
   if (newLockState == LOCKED)
       mutexLock(this->accountReadLock);
   else mutexUnlock(this->accountReadLock);
}

void Account::setAccountWriteLock(LockState newLockState) {
   if (newLockState == LOCKED)
       mutexLock(this->accountWriteLock);
   else mutexUnlock(this->accountWriteLock);
}

void Account::incReadCount() {
    this->readCount++;
}

void Account::decReadCount() {
    this->readCount--;
}

void Account::printAccount() {
    cout << "Account " << this->accountID << ": Balance - " << this->balance
    << " $, Account Password - " << setw(4) << setfill('0') << this->password << endl;
}
