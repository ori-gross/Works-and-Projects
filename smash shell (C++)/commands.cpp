//********************************************
#include "commands.h"
//********************************************
// function name: ExeCmd
// Description: interperts and executes built-in commands
// Parameters: pointer to jobs, command string
// Returns: 0 - success,1 - failure
//**************************************************************************************
int ExeCmd(Jobs* jobs, char* lineSize, string cmdString, string* old_pwd, 
		   int* fg_job_id, int* fg_job_pid, string* fg_job_cmd) 
{
	char* cmd;
    vector<string> args; // Use std::vector instead of a raw array
    const char* delimiters = " \t\n";
    int num_arg = 0;
    bool illegal_cmd = false; // illegal command
	bool perror_flag = false; // system call fail
	string perror_cmd;
	string print_error;
	string pwd;
    cmd = strtok(lineSize, delimiters);
    if (cmd == nullptr) return 0;     
    args.push_back(cmd);
	while ((cmd = strtok(nullptr, delimiters)) != nullptr && num_arg < MAX_ARG - 1) {
        	args.push_back(cmd);
        	num_arg++; 
	}
/*************************************************/
// Built in Commands PLEASE NOTE NOT ALL REQUIRED
// ARE IN THIS CHAIN OF IF COMMANDS. PLEASE ADD
// MORE IF STATEMENTS AS REQUIRED
/*************************************************/
	if (args[0] == "cd") 
	{		
		// checks for errors
		if (num_arg > 1) {
			cmdString = "cd: too many arguments";
			illegal_cmd = true;
		}
		else if ((*old_pwd).size() == 0 && args[1] == "-") {
			cmdString = "cd: OLDPWD not set";
			illegal_cmd = true;
		}
		// get the updated pwd
		if (!illegal_cmd) {
			char buf[BUF_SIZE]; 	   
			if(getcwd(buf, BUF_SIZE) != NULL) {
				pwd = buf;
			}
			else {
				perror_flag = true;
				perror_cmd = "getcwd ";
			}
		}
		if (!illegal_cmd && !perror_flag) { 
			// no errors and have the current pwd -> update the pwd and the old_pwd and change directory
			if (args[1] == "-") {
				string tmp_pwd;
				tmp_pwd = pwd;
				pwd = *old_pwd;
				*old_pwd = tmp_pwd;
				if (chdir(pwd.c_str()) == -1) {
					perror_flag = true;
					perror_cmd = "chdir ";
				}
			}
			else if (args[1] == "..") {
				if (pwd == "/") { // check if we are already in the root directory
					*old_pwd = pwd;
				}
				else { // we are not in the root directory
					*old_pwd = pwd;
					// check if we are in the direct son of the root directory
					if ((count(pwd.begin(),pwd.end(),'/')) == 1) {
						pwd = "/";
					}
					else { // we are not in the direct son of the root directory
						size_t lastSlashPos = (pwd).find_last_of('/');
						pwd = (pwd).substr(0, lastSlashPos);
					}
					if(chdir(pwd.c_str()) == -1) {
						perror_flag = true;
						perror_cmd = "chdir ";
					}
						
				}
			}
			else {
				if (!(chdir(args[1].c_str()))) {
					*old_pwd = pwd;
					pwd = args[1];
				}
				else {
					perror_flag = true;
					perror_cmd = "chdir ";
				}
			}
		}
	} 
	/*************************************************/
	else if (args[0] == "pwd")
	{
    	char buf[BUF_SIZE];
		// checks that the getcwd function succeeded before printing
		if (getcwd(buf, BUF_SIZE) != NULL) {
			pwd = buf;
			cout << pwd << endl;
		}
		else {
			perror_flag = true;
			perror_cmd = "getcwd ";
		}
	}
	/*************************************************/
	else if (args[0] == "jobs") 
	{
		sort(jobs->first_job(), jobs->last_job(), compare_job);
		jobs->print_jobs();
	}
	/*************************************************/
	else if (args[0] == "showpid")
	{
		pid_t pid = getpid();
		cout << "smash pid is " << pid << endl;
	}
	/*************************************************/
	else if (args[0] == "fg") 
	{	
		//check errors
		if (num_arg == 1 && isNumeric(args[1]) && !jobs->find_job(stoi(args[1]))) {
			cmdString = "fg: job-id " + args[1] + " does not exist";
			illegal_cmd = true;
		}
		else if (jobs->is_empty() && num_arg == 0) {
			cmdString = "fg: jobs list is empty";
			illegal_cmd = true;	
		}
		else if ((num_arg>0) && ((num_arg>=2) || (!isNumeric(args[1])))) {
			cmdString = "fg: invalid arguments";
			illegal_cmd = true;	
		}
		// no errors
		else {
			int job_id;
			if(num_arg == 0) job_id = jobs->get_max_job_id(); // get job max id from jobs if no arguments
			else job_id = stoi(args[1]);
			*fg_job_id = job_id;
			*fg_job_pid = jobs->get_job_by_id(job_id)->get_pid();
			*fg_job_cmd = jobs->get_job_by_id(job_id)->get_command();
			cout << *fg_job_cmd << " : " << *fg_job_pid << endl;
			if (jobs->get_job_by_id(job_id)->get_mode() == stopped) { //if the job is stopped - send SIGCONT
				kill(*fg_job_pid, SIGCONT);
			}
			jobs->delete_job(job_id);
			int status; // Variable to store the exit status
			int retval = waitpid(*fg_job_pid, &status, WUNTRACED); // wait until the child job stopped/terminate
			if (retval == -1) {
				perror_flag = true;
				perror_cmd = "waitpid ";
			}
			if (retval == *fg_job_pid) { // the child job terminate - no fg_job are exist
				*fg_job_id = -2;
				*fg_job_pid = -2;
				*fg_job_cmd = "";
			}
		}
	} 
	/*************************************************/
	else if (args[0] == "bg") 
	{
		//check for errors
  		if (num_arg == 1 && isNumeric(args[1]) && !jobs->find_job(stoi(args[1]))) {
			cmdString = "bg: job-id " + args[1] + " does not exist";
			illegal_cmd = true;	
		}
		else if (num_arg == 1 && isNumeric(args[1]) && 
				(jobs->get_job_by_id(stoi(args[1]))->get_mode()) != stopped) {
			cmdString = "bg: job-id " + args[1] + " is already running in the background";
			illegal_cmd = true;	
		}
		else if (!(jobs->find_stopped_job()) && (num_arg == 0)){
			cmdString = "bg: there are no stopped jobs to resume";
			illegal_cmd = true;	
		}
		else if ((num_arg>0) && ((num_arg>=2) || (!isNumeric(args[1])))) {
			cmdString = "bg: invalid arguments";
			illegal_cmd = true;	
		}
		// no errors
		else {
			int job_id;
			if(num_arg == 0) // get job max id from jobs if no arguments
				job_id = jobs->get_max_stopped_job_id();
			else job_id = stoi(args[1]);
			Job* bg_job = jobs->get_job_by_id(job_id); 
			cout << bg_job->get_command() << " : " << bg_job->get_pid() << endl;
			bg_job->set_mode(bg);
			kill(bg_job->get_pid(), SIGCONT); // send SIGCONT to the stopped job
		}
	}
	/*************************************************/
	else if (args[0] == "quit")
	{
		if (num_arg == 1 && args[1] == "kill") {
			for (auto& job : jobs->get_jobs()) { // do it for all the jobs that in the jobs vector
				int pid = job.get_pid();
				cout << "[" << job.get_job_id() << "] "  << job.get_command() << " - "; 
				cout << "Sending SIGTERM... " << flush;
				kill(pid, SIGTERM);
				sleep(5);
				int result = kill(pid, 0);
				if (result == 0) {
					cout << "Done." << endl;
				}
				else { //SIGTERM didn't work
					kill(pid, SIGKILL);
					cout << "(5 sec passed) Sending SIGKILL... Done." << endl;
				}
			}    		
		}
		exit(0);
	} 
	/*************************************************/
	else if (args[0] == "kill")
	{ 
		int signum;
		//check errors
		if (num_arg == 2 && isNumeric(args[2]) && !jobs->find_job(stoi(args[2]))) {
			cmdString = "kill: job-id " + args[2] + " does not exist";
			illegal_cmd = true;	
		}
		else if(num_arg != 2 || !isValidKill(num_arg, args[1], args[2], &signum)) {
			cmdString = "kill: invalid arguments";
			illegal_cmd = true;	
		}
		// no errors
		else {
			int job_id = stoi(args[2]);
			Job* kill_job = jobs->get_job_by_id(job_id);
			cout << "signal number " << signum << " was sent to pid " << kill_job->get_pid() << endl;
			kill(kill_job->get_pid(), signum);			
		}	
	} 
	/*************************************************/	
	else if (args[0] == "diff") 
	{
   		bool is_diff = false;
		if(num_arg != 2) {
			cmdString = "diff: invalid arguments";
			illegal_cmd = true;	
		}
		else {
			ifstream file1(args[1]), file2(args[2]);
    		string line1, line2;
    		while (getline(file1, line1) && getline(file2, line2)) {
        		if (line1 != line2) { // Files are different
					is_diff = true;
					break; 
				}    	
   	 		}
			// the while loop stopped on file1, should getline for file 2 for equality
			if(file1.eof()) getline(file2, line2); 
			if (line1 != line2) {  // Files are different
					is_diff = true;
			}
			if (is_diff) {
				cout << "1" << endl;
			}
			else { // files are match
				cout << "0" << endl;
			}
		}		 
	} 
	/*************************************************/	
	else // external command 
	{
 		int max_job_id = jobs->get_max_job_id();
		ExeExternal(args, cmdString, max_job_id, fg_job_id, fg_job_pid, fg_job_cmd);
	}
	// print errors to cout
	if (illegal_cmd == true)
	{
		cout << "smash error: " << cmdString << endl;
		return 1;
	}
	// print perror
	if (perror_flag == true)
	{
		print_error = "smash error: " + perror_cmd + "failed";
		perror(print_error.c_str());
		return 1;
	}
    return 0;
}
//**************************************************************************************
// function name: ExeExternal
// Description: executes external command
// Parameters: external command arguments, external command string
// Returns: void
//**************************************************************************************
void ExeExternal(vector<string> args, string cmdString, int max_job_id, int* fg_job_id, int* fg_job_pid, string* fg_job_cmd)
{
	int pid;
	int status; // Variable to store the exit status for waitpid
	int retval;
	vector<char*> cArgs;
	// Convert vector of strings to array of C-style strings
	for (const auto& arg : args) {
    	cArgs.push_back(const_cast<char*>(arg.c_str()));
	}
	cArgs.push_back(nullptr);
    switch(pid = fork())
	{
    	case -1: 
					perror("smash error: fork failed");
					break;
        case 0:
                	// Child Process
					setpgrp();
					retval = execv(cArgs[0], cArgs.data());
					if(retval == -1) {
        				perror("smash error: execv failed");
						exit(EXIT_FAILURE);
					}
					exit(0);
					break;
		default:
					*fg_job_id = max_job_id + 1;
					*fg_job_pid = pid;
					*fg_job_cmd = cmdString;
					if (waitpid(pid, &status, WUNTRACED) == -1) {
						perror("smash error: waitpid failed");
						exit(EXIT_FAILURE);
					}
						
	}
}
//**************************************************************************************
// function name: BgCmd
// Description: if command is in background, insert the command to jobs
// Parameters: command string, pointer to jobs
// Returns: 0- BG command -1- if not
//**************************************************************************************
int BgCmd(char* lineSize, Jobs* jobs)
{
	string new_job_cmd = lineSize;
	char* command;
	const char* delimiters = " \t\n";
	vector<string> args;
	int pid;
	int max_job_id = jobs->get_max_job_id();
	if (lineSize[strlen(lineSize)-1] == '&')
	{
		lineSize[strlen(lineSize)-1] = '\0';
		command = strtok(lineSize, delimiters);
    	if (command == nullptr)
        	return 0; 
    	args.push_back(command);
    	while ((command = strtok(nullptr, delimiters)) != nullptr) {
        	args.push_back(command); 
		}
		// Convert vector of strings to array of C-style strings
		vector<char*> cArgs;
		for (const auto& arg : args) {
    		cArgs.push_back(const_cast<char*>(arg.c_str()));
		}
		cArgs.push_back(nullptr);
		switch(pid = fork())
		{
    		case -1: 
					perror("smash error: fork failed");
					break;
        	case 0:
                	// Child Process
               		setpgrp();
					if (execvp(cArgs[0], cArgs.data()) == -1)
        				perror("smash error: execvp failed");
					break;
			default:
					jobs->delete_finished_jobs();
					Job *new_job = new Job(max_job_id+1, pid, bg, new_job_cmd);
					jobs->add_job(*new_job);
					break;		
		}
		return 0;
	}
	return -1;
}

// check if the string composed for numbers only
bool isNumeric(const string str) {
    for (char c : str) {
        if (c < '0' || c > '9') {
            return false;
        }
    }
    return true;
}
// check if the arguments are valid and extract the signum order from arg1
bool isValidKill(int num_arg, const string arg1, const string arg2, int *signum) {
	if(arg1[0] != '-') return false;
	string new_arg1 = arg1.substr(1);
	if(!isNumeric(new_arg1)) return false;
	if(!isNumeric(arg2)) return false;
	*signum = stoi(new_arg1);
	return true;
}
