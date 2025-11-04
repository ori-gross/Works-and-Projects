#!/usr/bin/env python3
"""
Performance testing script for binary translation project.
Runs normal cc1 execution and pin tool with different profiling times,
collects timing data and outputs results in CSV format.
"""

import subprocess
import time
import re
import csv
import os
import sys
from typing import List, Tuple, Dict, Any

class PerformanceTester:
    def __init__(self):
        self.num_runs = 10
        self.prof_times = [1, 2, 3, 4, 5, 6]
        self.cc1_path = "../../../../final_project/cc1"
        self.expr_i_path = "../../../../final_project/expr.i"
        self.pin_path = "../../../pin"
        self.pin_tool = "./obj-intel64/project.so"
        self.expr_s_path = "../../../../final_project/expr.s"
        self.expr_ref_s_path = "../../../../final_project/expr_ref.s"
        self.max_retries = 3  # Maximum number of retries for failed runs
        
        # Results storage
        self.results = {
            'normal': {'real_times': [], 'user_times': [], 'sys_times': []},
            'pin_runs': {}
        }
        
        for prof_time in self.prof_times:
            self.results['pin_runs'][prof_time] = {
                'real_times': [],
                'user_times': [],
                'sys_times': [],
                'tc_times': []
            }

    def run_command(self, command: List[str], timeout: int = 300) -> Tuple[float, float, float, str, str]:
        """
        Run a command and return real time, user time, sys time, stdout, stderr.
        Returns timing in seconds.
        """
        try:
            start_time = time.time()
            result = subprocess.run(
                command,
                capture_output=True,
                text=True,
                timeout=timeout,
                cwd=os.getcwd()
            )
            end_time = time.time()
            
            real_time = end_time - start_time
            
            # Parse timing from time command output if available
            user_time = 0.0
            sys_time = 0.0
            if result.returncode == 0:
                # Look for time command output in stderr
                time_output = result.stderr
                if time_output:
                    # Parse time command output format: "14.55user 0.29system 0:14.89elapsed"
                    # or "real 0m1.234s user 0m0.567s sys 0m0.123s"
                    
                    # Try new format first: "14.55user 0.29system 0:14.89elapsed"
                    user_match = re.search(r'([\d.]+)user', time_output)
                    sys_match = re.search(r'([\d.]+)system', time_output)
                    elapsed_match = re.search(r'(\d+):([\d.]+)elapsed', time_output)
                    
                    if user_match and sys_match and elapsed_match:
                        user_time = float(user_match.group(1))
                        sys_time = float(sys_match.group(1))
                        elapsed_minutes = int(elapsed_match.group(1))
                        elapsed_seconds = float(elapsed_match.group(2))
                        real_time = elapsed_minutes * 60 + elapsed_seconds
                    else:
                        # Try old format: "real 0m1.234s user 0m0.567s sys 0m0.123s"
                        real_match = re.search(r'real\s+(\d+)m([\d.]+)s', time_output)
                        user_match = re.search(r'user\s+(\d+)m([\d.]+)s', time_output)
                        sys_match = re.search(r'sys\s+(\d+)m([\d.]+)s', time_output)
                        
                        if real_match and user_match and sys_match:
                            real_minutes = int(real_match.group(1))
                            real_seconds = float(real_match.group(2))
                            user_minutes = int(user_match.group(1))
                            user_seconds = float(user_match.group(2))
                            sys_minutes = int(sys_match.group(1))
                            sys_seconds = float(sys_match.group(2))
                            
                            real_time = real_minutes * 60 + real_seconds
                            user_time = user_minutes * 60 + user_seconds
                            sys_time = sys_minutes * 60 + sys_seconds
                        else:
                            print(f"Could not parse time output: {time_output}")
                else:
                    print("No time command output found")
            
            return real_time, user_time, sys_time, result.stdout, result.stderr
            
        except subprocess.TimeoutExpired:
            print(f"Command timed out after {timeout} seconds: {' '.join(command)}")
            return 0.0, 0.0, 0.0, "", "Timeout"
        except Exception as e:
            print(f"Error running command: {e}")
            return 0.0, 0.0, 0.0, "", str(e)

    def extract_tc_time(self, output: str) -> float:
        """
        Extract TC creation time from pin tool output.
        Looks for line like "create_tc took: 3.62 seconds"
        """
        tc_time_match = re.search(r'create_tc took:\s+([\d.]+)\s+seconds', output)
        if tc_time_match:
            return float(tc_time_match.group(1))
        return 0.0

    def compare_output_files(self) -> bool:
        """
        Compare expr.s with expr_ref.s to ensure they are identical.
        Returns True if files are identical, False otherwise.
        """
        try:
            if not os.path.exists(self.expr_s_path):
                print(f"    Warning: {self.expr_s_path} not found")
                return False
            
            if not os.path.exists(self.expr_ref_s_path):
                print(f"    Warning: {self.expr_ref_s_path} not found")
                return False
            
            with open(self.expr_s_path, 'rb') as f1, open(self.expr_ref_s_path, 'rb') as f2:
                return f1.read() == f2.read()
                
        except Exception as e:
            print(f"    Error comparing files: {e}")
            return False

    def run_normal_execution(self):
        """Run normal cc1 execution 10 times."""
        print("Running normal cc1 execution...")
        
        for i in range(self.num_runs):
            print(f"  Run {i+1}/{self.num_runs}")
            command = ["time", self.cc1_path, self.expr_i_path]
            print(f"    Command: {' '.join(command)}")
            
            # Run with retry logic for file comparison
            for retry in range(self.max_retries):
                real_time, user_time, sys_time, stdout, stderr = self.run_command(command)
                
                # Check if output files match
                if self.compare_output_files():
                    print(f"    ✓ Output files match")
                    break
                else:
                    print(f"    ⚠ Output files don't match (attempt {retry + 1}/{self.max_retries})")
                    if retry < self.max_retries - 1:
                        print(f"    Retrying...")
                    else:
                        print(f"    ⚠ Max retries reached, using this run anyway")
            
            self.results['normal']['real_times'].append(real_time)
            self.results['normal']['user_times'].append(user_time)
            self.results['normal']['sys_times'].append(sys_time)
            
            print(f"    Real: {real_time:.3f}s, User: {user_time:.3f}s, Sys: {sys_time:.3f}s")

    def run_pin_execution(self):
        """Run pin tool with different profiling times."""
        print("Running pin tool executions...")
        
        for prof_time in self.prof_times:
            print(f"  Profiling time {prof_time}...")
            
            for i in range(self.num_runs):
                print(f"    Run {i+1}/{self.num_runs}")
                command = [
                    "time", self.pin_path, "-t", self.pin_tool,
                    f"-prof_time", str(prof_time), "-create_tc2", "--",
                    self.cc1_path, self.expr_i_path
                ]
                print(f"    Command: {' '.join(command)}")
                
                # Run with retry logic for file comparison
                for retry in range(self.max_retries):
                    real_time, user_time, sys_time, stdout, stderr = self.run_command(command)
                    tc_time = self.extract_tc_time(stdout + stderr)
                    
                    # Check if output files match
                    if self.compare_output_files():
                        print(f"      ✓ Output files match")
                        break
                    else:
                        print(f"      ⚠ Output files don't match (attempt {retry + 1}/{self.max_retries})")
                        if retry < self.max_retries - 1:
                            print(f"      Retrying...")
                        else:
                            print(f"      ⚠ Max retries reached, using this run anyway")
                
                self.results['pin_runs'][prof_time]['real_times'].append(real_time)
                self.results['pin_runs'][prof_time]['user_times'].append(user_time)
                self.results['pin_runs'][prof_time]['sys_times'].append(sys_time)
                self.results['pin_runs'][prof_time]['tc_times'].append(tc_time)
                
                print(f"      Real: {real_time:.3f}s, User: {user_time:.3f}s, Sys: {sys_time:.3f}s, TC: {tc_time:.3f}s")

    def calculate_averages(self, times: List[float]) -> float:
        """Calculate average of a list of times."""
        return sum(times) / len(times) if times else 0.0

    def write_csv_results(self, filename: str = "performance_results.csv"):
        """Write results to CSV file."""
        print(f"Writing results to {filename}...")
        
        with open(filename, 'w', newline='') as csvfile:
            writer = csv.writer(csvfile)
            
            # Normal run results
            normal_real_avg = self.calculate_averages(self.results['normal']['real_times'])
            normal_user_avg = self.calculate_averages(self.results['normal']['user_times'])
            normal_sys_avg = self.calculate_averages(self.results['normal']['sys_times'])
            
            normal_real_row = ["normal run real"] + self.results['normal']['real_times'] + ["avg"] + [normal_real_avg]
            normal_user_row = ["normal run user"] + self.results['normal']['user_times'] + ["avg"] + [normal_user_avg]
            normal_sys_row = ["normal run sys"] + self.results['normal']['sys_times'] + ["avg"] + [normal_sys_avg]
            
            writer.writerow(normal_real_row)
            writer.writerow(normal_user_row)
            writer.writerow(normal_sys_row)
            
            # Pin run results
            for prof_time in self.prof_times:
                pin_data = self.results['pin_runs'][prof_time]
                
                real_avg = self.calculate_averages(pin_data['real_times'])
                user_avg = self.calculate_averages(pin_data['user_times'])
                sys_avg = self.calculate_averages(pin_data['sys_times'])
                tc_avg = self.calculate_averages(pin_data['tc_times'])
                
                real_row = [f"pin run prof time {prof_time} real"] + pin_data['real_times'] + ["avg"] + [real_avg]
                user_row = [f"pin run prof time {prof_time} user"] + pin_data['user_times'] + ["avg"] + [user_avg]
                sys_row = [f"pin run prof time {prof_time} sys"] + pin_data['sys_times'] + ["avg"] + [sys_avg]
                tc_row = [f"pin run prof time {prof_time} create tc"] + pin_data['tc_times'] + ["avg"] + [tc_avg]
                
                writer.writerow(real_row)
                writer.writerow(user_row)
                writer.writerow(sys_row)
                writer.writerow(tc_row)
        
        print(f"Results written to {filename}")

    def print_summary(self):
        """Print a summary of the results."""
        print("\n" + "="*60)
        print("PERFORMANCE TEST SUMMARY")
        print("="*60)
        
        # Normal execution summary
        normal_real_avg = self.calculate_averages(self.results['normal']['real_times'])
        normal_user_avg = self.calculate_averages(self.results['normal']['user_times'])
        normal_sys_avg = self.calculate_averages(self.results['normal']['sys_times'])
        
        print(f"Normal execution (average of {self.num_runs} runs):")
        print(f"  Real time: {normal_real_avg:.3f}s")
        print(f"  User time: {normal_user_avg:.3f}s")
        print(f"  Sys time: {normal_sys_avg:.3f}s")
        print()
        
        # Pin execution summary
        print(f"Pin tool execution (average of {self.num_runs} runs):")
        for prof_time in self.prof_times:
            pin_data = self.results['pin_runs'][prof_time]
            real_avg = self.calculate_averages(pin_data['real_times'])
            user_avg = self.calculate_averages(pin_data['user_times'])
            sys_avg = self.calculate_averages(pin_data['sys_times'])
            tc_avg = self.calculate_averages(pin_data['tc_times'])
            
            overhead_real = ((real_avg - tc_avg - normal_real_avg) / normal_real_avg) * 100
            overhead_user = ((user_avg - tc_avg - normal_user_avg) / normal_user_avg) * 100
            
            print(f"  Prof time {prof_time}:")
            print(f"    (Real time - TC creation): {real_avg-tc_avg:.3f}s (overhead: {overhead_real:+.1f}%)")
            print(f"    (User time - TC creation): {user_avg-tc_avg:.3f}s (overhead: {overhead_user:+.1f}%)")
            print(f"    Sys time: {sys_avg:.3f}s")
            print(f"    TC creation: {tc_avg:.3f}s")
            print()

    def run_all_tests(self):
        """Run all performance tests."""
        print("Starting performance tests...")
        print(f"Number of runs per test: {self.num_runs}")
        print(f"Profiling times: {self.prof_times}")
        print()
        
        # Check if required files exist
        if not os.path.exists(self.cc1_path):
            print(f"Error: {self.cc1_path} not found!")
            return False
        
        if not os.path.exists(self.expr_i_path):
            print(f"Error: {self.expr_i_path} not found!")
            return False
        
        if not os.path.exists(self.pin_tool):
            print(f"Error: {self.pin_tool} not found!")
            print("Make sure you're running from the correct directory and the tool is compiled.")
            return False
        
        if not os.path.exists(self.expr_ref_s_path):
            print(f"Warning: {self.expr_ref_s_path} not found!")
            print("File comparison will be skipped. This may affect result reliability.")
            print("Consider creating a reference file by running cc1 once and saving the output.")
        
        try:
            # Run normal execution
            self.run_normal_execution()
            print()
            
            # Run pin executions
            self.run_pin_execution()
            print()
            
            # Write results
            self.write_csv_results()
            
            # Print summary
            self.print_summary()
            
            print("Performance tests completed successfully!")
            return True
            
        except KeyboardInterrupt:
            print("\nTests interrupted by user.")
            return False
        except Exception as e:
            print(f"Error during testing: {e}")
            return False

def main():
    """Main function."""
    print("Binary Translation Performance Testing Script")
    print("=" * 50)
    
    # Check if we're in the right directory
    if not os.path.exists("./obj-intel64/project.so"):
        print("Error: project.so not found!")
        print("Please run this script from the directory containing obj-intel64/project.so")
        print("Expected location: $PIN_ROOT/source/tools/SimpleExamples/")
        sys.exit(1)
    
    tester = PerformanceTester()
    success = tester.run_all_tests()
    
    if success:
        print("\nAll tests completed successfully!")
        sys.exit(0)
    else:
        print("\nTests failed!")
        sys.exit(1)

if __name__ == "__main__":
    main()
