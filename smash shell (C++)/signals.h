#ifndef _SIGS_H
#define _SIGS_H
#include <sys/types.h>
#include <sys/wait.h>
#include <unistd.h> 
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <signal.h>
#include <iostream>
#include <csignal>
#include "jobs.h"
#include "smash.h"
using namespace std;

void Ctrl_C_Handler(int signum);
void Ctrl_Z_Handler(int signum);

#endif
