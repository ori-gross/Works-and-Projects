#ifndef _JOBS_H
#define _JOBS_H

#include <stdio.h>
#include <stdlib.h>
#include <iostream>
#include <string>
#include <vector>
#include <algorithm>
#include <time.h>
#include <sys/wait.h>

#define MAX_LINE_SIZE 80

using namespace std;

enum jobMode { fg = 1, bg = 2, stopped = 3 };

class Job
{
private:
    int job_id;
    int process_id;
    jobMode mode;
    string command;
    time_t start_time;
public:
    Job(int job_id, int process_id, jobMode mode, string command);
    ~Job();
    int get_job_id() const;
    void set_job_id(int job_id);
    int get_pid() const;
    jobMode get_mode() const;
    void set_mode(jobMode new_mode);
    string get_command() const;
    void set_start_time();
    time_t get_seconds_elapsed(const time_t start_time);
    void print_job();
};

class Jobs
{
private:
    vector<Job> jobs;
public:
    Jobs();
    ~Jobs();
    vector<Job> get_jobs();
    int get_max_job_id();
    void add_job(Job job);
    void delete_job(int job_id);
    void delete_finished_jobs();
    void print_jobs();
    bool find_job(int job_id);
    Job* get_job_by_id(int job_id);
    int get_max_stopped_job_id(); 
    bool is_empty();
    Job* first_job();
    Job* last_job();
    bool find_stopped_job() const;
    
};

bool compare_job(Job a, Job b);

#endif
