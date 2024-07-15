//#include <pthread.h>
#include "atm.h"

vector<Account*> bankAccounts;    // The Bank's Accounts
ofstream logFile("log.txt");      // log.txt
pthread_mutex_t *logLock;         // Lock for log.txt
pthread_mutex_t *printScreenLock; // Lock for STDOUT and STDERR
// read-write locks for Data Structure
pthread_mutex_t *bankAccountsReadLock;
pthread_mutex_t *bankAccountsWriteLock;
size_t bankAccountsReadCount;

// Helper functions 1/2
Account* findAccount(int accountID) {
    for (auto account : bankAccounts) {
        if (account->getAccountID() == accountID)
            return account;
    }
    return nullptr;
}

// Helper functions 2/2
bool compareAccounts(const Account* a, const Account* b) {
    return a->getAccountID() < b->getAccountID();
}

// Accounts functions 1/6
void openAccount(size_t atmID, int account, int password, int initial_amount) {
        sleep(1);
        if (findAccount(account) != nullptr) { // Check if the account already exists
            mutexLock(logLock);
            logFile << "Error " << atmID << ": Your transaction failed - account with the same id exists" << endl;
            mutexUnlock(logLock);
        }
        else { // Account doesn't exists - open new account
            Account *newAccount = new Account(account, password, initial_amount);
            bankAccounts.push_back(newAccount);
            sort(bankAccounts.begin(), bankAccounts.end(), compareAccounts);
            mutexLock(logLock);
            logFile << atmID << ": New account id is " << account << " with password " << setw(4) << setfill('0') 
            << password << " and initial balance " << initial_amount << endl;
            mutexUnlock(logLock);
        }
}

// Accounts functions 2/6
void deposit(size_t atmID, int account, int password, int amount) {
    Account *currAccount = findAccount(account);
    if (currAccount == nullptr) { // Check if the account exists
        sleep(1);
        mutexLock(logLock);
        logFile << "Error " << atmID << ": Your transaction failed - account id " << account
        << " does not exist" << endl;
        mutexUnlock(logLock);
    }
    else if (currAccount->getPassword() != password) { // The password is not valid
        sleep(1);
        mutexLock(logLock);
        logFile << "Error " << atmID << ": Your transaction failed - password for account id " 
        << account << " is incorrect" << endl;
        mutexUnlock(logLock);
    }
    else { // Everything is valid
        currAccount->setAccountWriteLock(LOCKED);
        sleep(1);
        currAccount->setDepositBalance(amount);
        mutexLock(logLock);
        logFile << atmID << ": Account " << account << " new balance is " << currAccount->getBalance()
        << " after " << amount << " $ was deposited " << endl;
        mutexUnlock(logLock);
        currAccount->setAccountWriteLock(UNLOCKED);
    }
}

// Accounts functions 3/6
void withdraw(size_t atmID, int account, int password, int amount) {
    Account *currAccount = findAccount(account);
    if (currAccount == nullptr) { // Check if the account exists
        sleep(1);
        mutexLock(logLock);
        logFile << "Error " << atmID << ": Your transaction failed - account id " << account
        << " does not exist" << endl;
        mutexUnlock(logLock);
    }
    else if (currAccount->getPassword() != password) { // The password is not valid
        sleep(1);
        mutexLock(logLock);
        logFile << "Error " << atmID << ": Your transaction failed - password for account id " 
        << account << " is incorrect" << endl;
        mutexUnlock(logLock);
    }
    else {
        currAccount->setAccountWriteLock(LOCKED);
        sleep(1);
        // The amount that were request is bigger than the current amount
        if (amount > currAccount->getBalance()) {
            mutexLock(logLock);
            logFile << "Error " << atmID << ": Your transaction failed - account id " 
            << account << " balance is lower than " << amount << endl;
            mutexUnlock(logLock);
        }
        else { // Everything is valid
            currAccount->setWithdrawBalance(amount);
            mutexLock(logLock);
            logFile << atmID << ": Account " << account << " new balance is " << currAccount->getBalance()
            << " after " << amount << " $ was withdrew" << endl;
            mutexUnlock(logLock);
        }
        currAccount->setAccountWriteLock(UNLOCKED);
    }
}

// Accounts functions 4/6
void balance(size_t atmID, int account, int password) {
    Account *currAccount = findAccount(account);
    if (currAccount == nullptr) { // Check if the account exists
        sleep(1);
        mutexLock(logLock);
        logFile << "Error " << atmID << ": Your transaction failed - account id "
        << account << " does not exist" << endl;
        mutexUnlock(logLock);
    }
    else {
        currAccount->setAccountReadLock(LOCKED);
        currAccount->incReadCount();
        if (currAccount->getReadCount() == 1)
            currAccount->setAccountWriteLock(LOCKED);
        currAccount->setAccountReadLock(UNLOCKED);
        sleep(1);
        if (currAccount->getPassword() != password) { // The password is not valid
            mutexLock(logLock);
            logFile << "Error " << atmID << ": Your transaction failed - password for account id " 
            << account << " is incorrect" << endl;
            mutexUnlock(logLock);
        }
        else { // Everything is valid
            mutexLock(logLock);
            logFile << atmID << ": Account " << account << " balance is " << currAccount->getBalance() << endl;
            mutexUnlock(logLock);
        }
        currAccount->setAccountReadLock(LOCKED);
        currAccount->decReadCount();
        if (currAccount->getReadCount() == 0)
            currAccount->setAccountWriteLock(UNLOCKED);
        currAccount->setAccountReadLock(UNLOCKED);
    }
}

// Accounts functions 5/6
void quit(size_t atmID, int account, int password) {
    Account *currAccount = findAccount(account);
    if (currAccount == nullptr) { // Check if the account exists
        sleep(1);
        mutexLock(logLock);
        logFile << "Error " << atmID << ": Your transaction failed - account id "
        << account << " does not exist" << endl;
        mutexUnlock(logLock);
    }
    else if (currAccount->getPassword() != password) { // The password is not valid
        sleep(1);
        mutexLock(logLock);
        logFile << "Error " << atmID << ": Your transaction failed - password for account id " 
        << account << " is incorrect" << endl;
        mutexUnlock(logLock);
    }
    else { // Everything is valid
        sleep(1);
        int lastBalance = currAccount->getBalance();
        bankAccounts.erase(remove_if(bankAccounts.begin(), bankAccounts.end(),
                           [account](const Account* a) {return a->getAccountID() == account;}),
                           bankAccounts.end());
        sort(bankAccounts.begin(), bankAccounts.end(), compareAccounts);
        delete currAccount;
        mutexLock(logLock);
        logFile << atmID << ": Account " << account << " is now closed. Balance was " << lastBalance << endl;
        mutexUnlock(logLock);
    }
}

// Accounts functions 6/6
void transfer(size_t atmID, int account, int password, int target_account, int amount) {
    Account *currAccount = findAccount(account);
    Account *currTargetAccount = findAccount(target_account);
    if (currAccount == nullptr) { // Check if the account exists
        sleep(1);
        mutexLock(logLock);
        logFile << "Error " << atmID << ": Your transaction failed - account id " << account
        << " does not exist" << endl;
        mutexUnlock(logLock);
    }
    else if (currTargetAccount == nullptr) { // Check if the account exists
        sleep(1);
        mutexLock(logLock);
        logFile << "Error " << atmID << ": Your transaction failed - account id " << target_account
        << " does not exist" << endl;
        mutexUnlock(logLock);
    }
    else if (currAccount->getPassword() != password) { // The password is not valid
        sleep(1);
        mutexLock(logLock);
        logFile << "Error " << atmID << ": Your transaction failed - password for account id " 
        << account << " is incorrect" << endl;
        mutexUnlock(logLock);
    }
    else { // Everything is valid
        if (currAccount->getAccountID() < currTargetAccount->getAccountID()) {
            currAccount->setAccountWriteLock(LOCKED);
            currTargetAccount->setAccountWriteLock(LOCKED);
        }
        else {
            currTargetAccount->setAccountWriteLock(LOCKED);
            currAccount->setAccountWriteLock(LOCKED);
        }
        sleep(1);
        if (amount > currAccount->getBalance()) {
            mutexLock(logLock);
            logFile << "Error " << atmID << ": Your transaction failed - account id " 
            << account << " balance is lower than " << amount << endl;
            mutexUnlock(logLock);
        }
        else {
            currAccount->setWithdrawBalance(amount);
            currTargetAccount->setDepositBalance(amount);
            mutexLock(logLock);
            logFile << atmID << ": Transfer " << amount << " from account " << account << " to account " <<
            target_account << " new account balance is " << currAccount->getBalance() << 
            " new target account balance is " << currTargetAccount->getBalance() << endl;
            mutexUnlock(logLock);
        }
        if (currAccount->getAccountID() < currTargetAccount->getAccountID()) {
            currTargetAccount->setAccountWriteLock(UNLOCKED);
            currAccount->setAccountWriteLock(UNLOCKED);
        }
        else {
            currAccount->setAccountWriteLock(UNLOCKED);
            currTargetAccount->setAccountWriteLock(UNLOCKED);
        }
    }
}

void bankOperation(string operationLine, size_t atmID) {
    // Parsing the operation line
    vector<string> args;
    string delimiter = " \t\n";
    size_t pos = 0;
    string token;
    while ((pos = operationLine.find_first_of(delimiter)) != string::npos) {
        token = operationLine.substr(0, pos);
        args.push_back(token);
        operationLine.erase(0, pos + 1);
    }
    if (!operationLine.empty())
        args.push_back(operationLine);
    // Starting the operation for the line
    string operation = args[0];
    int account = stoi(args[1]);
    int password = stoi(args[2]);
    if (operation == OPEN || operation == QUIT) {
        // bankAccount - before write
        mutexLock(bankAccountsWriteLock);
        if (operation == OPEN) {
            int initial_amount = stoi(args[3]);
            openAccount(atmID, account, password, initial_amount);
        }
        else { // operation == QUIT
            quit(atmID, account, password);
        }
        // bankAccount - after write
        mutexUnlock(bankAccountsWriteLock);
    }
    else { // DEPOSIT || WITHDRAW || BALANCE || TRANSFER
        // bankAccount - before read
        mutexLock(bankAccountsReadLock);
        bankAccountsReadCount++;
        if (bankAccountsReadCount == 1)
            mutexLock(bankAccountsWriteLock);
        mutexUnlock(bankAccountsReadLock);
        if (operation == DEPOSIT) {
            int amount = stoi(args[3]);
            deposit(atmID, account, password, amount);
        }
        else if (operation == WITHDRAW) {
            int amount = stoi(args[3]);
            withdraw(atmID, account, password, amount);
        }
        else if (operation == BALANCE) {
            balance(atmID, account, password);
        }
        else { // operation == TRANSFER
            int target_account = stoi(args[3]);
            int amount = stoi(args[4]);
            transfer(atmID, account, password, target_account, amount);
        }
        // bankAccount - after read
        mutexLock(bankAccountsReadLock);
        bankAccountsReadCount--;
        if (bankAccountsReadCount == 0)
            mutexUnlock(bankAccountsWriteLock);
        mutexUnlock(bankAccountsReadLock);
    }
}

// "atm main": Handle the atm's banking operations
void* handleATM(void* atmArgs) {
    HandleATMArgs* args = (HandleATMArgs*)(atmArgs);
    string atmInputFilename = args->atmInputFilename;
    size_t atmID = args->atmID;
    ifstream inputFile(atmInputFilename);
    if (!inputFile.is_open()) {
        mutexLock(printScreenLock);
        cerr << "Bank error: illegal arguments" << endl;
        mutexUnlock(printScreenLock);
        exit(-1);
    }
    string operationLine;
    while (getline(inputFile, operationLine)) {
        usleep(100*1000);
        bankOperation(operationLine, atmID);
    }
    inputFile.close(); // Close the file when done
    delete args;
    pthread_exit(0); // Exit the atm's thread
}
