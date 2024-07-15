#include "jobs.h"

Job::Job(int job_id, int process_id, jobMode mode, string command) : 
         job_id(job_id), process_id(process_id), mode(mode), command(command), start_time(time(nullptr)) {
}
Job::~Job() {
}
int Job::get_job_id() const {
    return this->job_id;
}
void Job::set_job_id(int job_id) {
    this->job_id=job_id;
}
int Job::get_pid() const {
    return this->process_id;
}
jobMode Job::get_mode() const{
    return this->mode;
}
void Job::set_mode(jobMode new_mode) {
    this->mode = new_mode;
}
string Job::get_command() const {
    return this->command;
}
void Job::set_start_time() {
    this->start_time=time(nullptr);
}
time_t Job::get_seconds_elapsed(time_t start_time) {
    return difftime(time(nullptr), start_time);
}
void Job::print_job() {
    cout << "[" << this->job_id << "] " << this->command << " : " 
    << this->process_id << " " << get_seconds_elapsed(this->start_time) << " secs";
    if(this->mode == stopped) {
        cout << " (stopped)";
    }
    cout << endl;
}

Jobs::Jobs() : jobs() {
}
Jobs::~Jobs() {
}
vector<Job> Jobs::get_jobs() {
    return this->jobs;
}
int Jobs::get_max_job_id() {
    int max_job_id = 0;
    for (auto& job : this->jobs) {
        if(job.get_job_id() > max_job_id) {
            max_job_id = job.get_job_id();
        }
    }
    return max_job_id;
}
void Jobs::add_job(Job job) {
    job.set_start_time();
    this->jobs.push_back(job);
}
void Jobs::delete_job(int job_id) {
    jobs.erase(remove_if(jobs.begin(), jobs.end(), [job_id](Job job){return job.get_job_id() == job_id;}),
               jobs.end());
}
void Jobs::delete_finished_jobs() {
    for (auto& job : this->jobs) {
        int job_id = job.get_job_id();
        int pid = job.get_pid();
        int status;
        pid_t result = waitpid(pid, &status, WNOHANG);
	    if (result != 0) { // check if job is finished
            delete_job(job_id);
        }   
    }
}
void Jobs::print_jobs() {
    for (auto& job : this->jobs) {
        job.print_job();
    }
}
bool Jobs::find_job(int job_id){
    for (auto& job : this->jobs) {
        if (job.get_job_id() == job_id) return true;
    }
    return false;
}
Job* Jobs::get_job_by_id(int job_id) {
    for (auto& job : this->jobs) {
        if(job.get_job_id() == job_id) {
            return &job;
        }
    }
    return nullptr;
}
int Jobs::get_max_stopped_job_id() {
    int max_stopped_job_id = 0;
    for (auto& job : this->jobs) {
        if(job.get_mode() == stopped && job.get_job_id() > max_stopped_job_id) {
            max_stopped_job_id = job.get_job_id();
        }
    }
    return max_stopped_job_id;
}
bool Jobs::is_empty() {
    return this->jobs.empty();
}
Job* Jobs::first_job() {
    return &(*this->jobs.begin());
}
Job* Jobs::last_job() {
    return &(*this->jobs.end());
}
bool Jobs::find_stopped_job() const {
    for (auto& job : this->jobs) {
        if (job.get_mode() == stopped) return true;
    }
    return false;
}

bool compare_job(Job a, Job b) {
    return a.get_job_id() < b.get_job_id();
}
