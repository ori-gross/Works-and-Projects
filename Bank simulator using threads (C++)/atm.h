#ifndef ATM_H
#define ATM_H

#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <iostream>
#include <vector>
#include <fstream>
#include <unistd.h>
#include <pthread.h>
#include <algorithm>
#include <iomanip>
#include "mutex.h"
#include "account.h"
#include "globals.h"

#define OPEN "O"
#define DEPOSIT "D"
#define WITHDRAW "W"
#define BALANCE "B"
#define QUIT "Q"
#define TRANSFER "T"

using namespace std;

// Returns a pointer to Account with accountID if in bankAccounts, else returns nullptr
Account* findAccount(int accountID);
// Compare function for sorting
bool compareAccounts(const Account* a, const Account* b);

// 6 banking operations
void openAccount(size_t atmID, int account, int password, int initial_amount);
void deposit(size_t atmID, int account, int password, int amount);
void withdraw(size_t atmID, int account, int password, int amount);
void balance(size_t atmID, int account, int password);
void quit(size_t atmID, int account, int password);
void transfer(size_t atmID, int account, int password, int target_account, int amount);

// Handle a banking operation
void bankOperation(string operationLine, size_t atmID);

// "atm main": Handle the atm's banking operations
void* handleATM(void* atmArgs);

#endif
