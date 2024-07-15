#ifndef _COMMANDS_H
#define _COMMANDS_H
#include <unistd.h> 
#include <stdio.h>
#include <time.h>
#include <stdlib.h>
#include <signal.h>
#include <string.h>
#include <cstring>
#include <sys/types.h>
#include <iostream>
#include <sstream>
#include <fstream>
#include <csignal>
#include <sys/wait.h>
#include "jobs.h"
#define MAX_LINE_SIZE 80
#define MAX_ARG 20
#define BUF_SIZE 1024
using namespace std;
int BgCmd(char* lineSize, Jobs* jobs);
int ExeCmd(Jobs* jobs, char* lineSize, string cmdString, string* old_pwd, int* fg_job_id, int* fg_job_pid, string* fg_job_cmd);
void ExeExternal(vector<string> args, string cmdString, int max_job_id, int* fg_job_id, int* fg_job_pid, string* fg_job_cmd);
bool isNumeric(const string str);
bool isValidKill(int num_arg, const string arg1, const string arg2, int* signum);
#endif
