#ifndef BANK_H
#define BANK_H

#include <cstdio>
#include <cstdlib>
#include <iostream>
#include <vector>
#include <fstream>
#include <unistd.h>
#include <cmath>
#include <pthread.h>
#include "mutex.h"
#include "account.h"
#include "globals.h"
#include "atm.h"

using namespace std;

// Charge commissions from all accounts every 3 seconds
void* chargeCommissions(void* arg);

// Print the current bank status every 0.5 seconds
void* printCurrentBankStatus(void* arg);

#endif
