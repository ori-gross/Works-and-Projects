/*	smash.cpp
main file. This file contains the main function of smash
*******************************************************************/
#include "smash.h"

char lineSize[MAX_LINE_SIZE]; 
Jobs* jobs = new Jobs();
string old_pwd;
int fg_job_id=-2;
int fg_job_pid=-2;
string fg_job_cmd;

//**************************************************************************************
// function name: main
// Description: main function of smash. get command from user and calls command functions
//**************************************************************************************
int main(int argc, char *argv[])
{
	string cmdString; 
	//signal declaretions
	signal(SIGINT, Ctrl_C_Handler);
	signal(SIGTSTP, Ctrl_Z_Handler);
	
/************************************/	
    while (1)
    {
		cout << "smash > ";
		cin.getline(lineSize, MAX_LINE_SIZE);
		cmdString = lineSize;    	
		jobs->delete_finished_jobs();
	 	if(!BgCmd(lineSize, jobs)) continue;	// background command
		ExeCmd(jobs, lineSize, cmdString, &old_pwd, &fg_job_id, &fg_job_pid, &fg_job_cmd);	// built in commands
		/* initialize for next line read*/
		lineSize[0]='\0';
		cmdString.clear();
	}
    return 0;
}
