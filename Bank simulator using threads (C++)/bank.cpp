#include "bank.h"

bool finishedOperations;    // True if all operations are finished
int bankPrivateAccount;     // The bank's money

void* chargeCommissions(void* arg) {
    int commissionPerc;
    while (!finishedOperations) {
        sleep(3);
        commissionPerc = rand()%5 + 1;
        // bankAccount - before read
        mutexLock(bankAccountsReadLock);
        bankAccountsReadCount++;
        if (bankAccountsReadCount == 1)
            mutexLock(bankAccountsWriteLock);
        mutexUnlock(bankAccountsReadLock);
        for (auto account : bankAccounts) { // Charge commission from each account
            account->setAccountWriteLock(LOCKED);
            int currBalacnce = account->getBalance();
            int commission = round((double)(commissionPerc * currBalacnce) / 100);
            account->setWithdrawBalance(commission);
            bankPrivateAccount += commission;
            mutexLock(logLock);
            logFile << "Bank: commissions of " << commissionPerc << " % were charged, the bank gained "
            << commission << " $ from account " << account->getAccountID() << endl;
            mutexUnlock(logLock);
            account->setAccountWriteLock(UNLOCKED);
        }
        // bankAccount - after read
        mutexLock(bankAccountsReadLock);
        bankAccountsReadCount--;
        if (bankAccountsReadCount == 0)
            mutexUnlock(bankAccountsWriteLock);
        mutexUnlock(bankAccountsReadLock);
    }
    pthread_exit(0);
}

void* printCurrentBankStatus(void* arg) {
    while (!finishedOperations) {
        usleep(500*1000);
        // bankAccount - before read
        mutexLock(bankAccountsReadLock);
        bankAccountsReadCount++;
        if (bankAccountsReadCount == 1)
            mutexLock(bankAccountsWriteLock);
        mutexUnlock(bankAccountsReadLock);
        for (auto account : bankAccounts) {
            account->setAccountReadLock(LOCKED);
            account->incReadCount();
            if (account->getReadCount() == 1)
                account->setAccountWriteLock(LOCKED);
            account->setAccountReadLock(UNLOCKED);
        }
        mutexLock(printScreenLock);
        printf("\033[2J");
        printf("\033[1;1H");
        cout << "Current Bank Status" << endl;
        for (auto account : bankAccounts) {
            account->printAccount(); // Print current account status
            account->setAccountReadLock(LOCKED);
            account->decReadCount();
            if (account->getReadCount() == 0)
                account->setAccountWriteLock(UNLOCKED);
            account->setAccountReadLock(UNLOCKED);
        }
        cout << "The Bank has " << bankPrivateAccount << " $" << endl;
        mutexUnlock(printScreenLock);
        // bankAccount - after read
        mutexLock(bankAccountsReadLock);
        bankAccountsReadCount--;
        if (bankAccountsReadCount == 0)
            mutexUnlock(bankAccountsWriteLock);
        mutexUnlock(bankAccountsReadLock);
    }
    pthread_exit(0);
}

int main(int argc, char *argv[])
{
    if (argc == 1) {
        cerr << "Bank error: illegal arguments" << endl;
        exit(-1);
    }
    size_t numOfATMs = argc - 1;
    pthread_t commissionThread, printThread;
    pthread_t *atmThreads = (pthread_t*)malloc(numOfATMs*sizeof(pthread_t));
    if (atmThreads == nullptr) // Memory allocation failed
        exit(-1);
    int retval;
    // Initializing globals
    if (!logFile.is_open()) {
        cerr << "Bank error: illegal arguments" << endl;
        exit(-1);
    }
    logLock = new pthread_mutex_t;
    mutexInit(logLock);
    printScreenLock = new pthread_mutex_t;
    mutexInit(printScreenLock);
    bankAccountsReadLock = new pthread_mutex_t;
    mutexInit(bankAccountsReadLock);
    bankAccountsWriteLock = new pthread_mutex_t;
    mutexInit(bankAccountsWriteLock);
    bankAccountsReadCount = 0;
    finishedOperations = false;
    bankPrivateAccount = 0;
    // Create the commission thread
    retval = pthread_create(&commissionThread, nullptr, chargeCommissions, nullptr);
    if (retval) {
        perror("Bank error: pthread_create failed");
        exit(-1);
    }
    // Create the printing thread
    retval = pthread_create(&printThread, nullptr, printCurrentBankStatus, nullptr);
    if (retval) {
        perror("Bank error: pthread_create failed");
        exit(-1);
    }
    // Create the ATMs threads
    for (size_t atmID = 1; atmID <= numOfATMs; atmID++) {
        HandleATMArgs* atmArgs = new HandleATMArgs{argv[atmID], atmID};
        retval = pthread_create(&atmThreads[atmID-1], nullptr, handleATM, atmArgs);
        if (retval) {
            perror("Bank error: pthread_create failed");
            exit(-1);
        }
    }
    // Wait for all ATMs threads to finish
    for (size_t i = 0; i < numOfATMs; i++) {
        retval = pthread_join(atmThreads[i], NULL);
        if (retval) {
            perror("Bank error: pthread_join failed");
            exit(-1);
        }
    }
    free(atmThreads);
    finishedOperations = true;
    // Wait for the commission thread to finish
    retval = pthread_join(commissionThread, NULL);
    if (retval) {
        perror("Bank error: pthread_join failed");
        exit(-1);
    }
    // Wait for the printing thread to finish
    retval = pthread_join(printThread, NULL);
    if (retval) {
        perror("Bank error: pthread_join failed");
        exit(-1);
    }
    logFile.close();
    // Destroying locks before finishing
    mutexDestroy(logLock);
    delete logLock;
    mutexDestroy(printScreenLock);
    delete printScreenLock;
    mutexDestroy(bankAccountsReadLock);
    delete bankAccountsReadLock;
    mutexDestroy(bankAccountsWriteLock);
    delete bankAccountsWriteLock;
    return 0;
}
