// smash.h
#ifndef SMASH_H
#define SMASH_H

#include <sys/types.h>
#include <sys/wait.h>
#include <unistd.h> 
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <string>
#include <signal.h>
#include "commands.h"
#include "signals.h"
#include "jobs.h"
#define MAX_LINE_SIZE 80
#define MAXARGS 20
#define BUF_SIZE 1024
using namespace std;

extern Jobs* jobs;
extern string old_pwd;
extern int fg_job_id;
extern int fg_job_pid;
extern string fg_job_cmd;

#endif // SMASH_H
