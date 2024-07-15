// signals.cpp
// contains signal handler funtions
// contains the function/s that set the signal handlers
/*******************************************/
#include "signals.h"

void Ctrl_C_Handler(int signum) {
   cout << "smash: caught ctrl-C" << endl;
   if (fg_job_id == -2) { // process is not running on the forground
      cout << "smash > "; // smash already was printted, so print again
      cout.flush();
   }   
   else { // process is running on the forground
      kill(fg_job_pid, SIGKILL);
      cout << "smash: process " << fg_job_pid << " was killed" << endl;
      fg_job_id = -2;
		fg_job_pid = -2;
		fg_job_cmd = "";
   }
   return;
}
void Ctrl_Z_Handler(int signum) {
   cout << "smash: caught ctrl-Z" << endl;
   if (fg_job_id == -2) { // process is not running on the forground
      cout << "smash > "; // smash already was printted, so print again
      cout.flush();
   }   
   else{  // process is running on the forground
      Job* new_job = new Job(fg_job_id, fg_job_pid , stopped, fg_job_cmd);
      jobs->add_job(*new_job);
      kill(fg_job_pid, SIGSTOP);
      cout << "smash: process " << fg_job_pid << " was stopped" << endl;
      fg_job_id = -2;
		fg_job_pid = -2;
		fg_job_cmd = "";
   }
   return;
}
