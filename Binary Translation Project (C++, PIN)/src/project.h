#ifndef PROJECT_H
#define PROJECT_H

#include "pin.H"
extern "C" {
#include "xed-interface.h"
}
#include <iostream>
#include <iomanip>
#include <fstream>
#include <sys/mman.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <malloc.h>
#include <errno.h>
#include <assert.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <values.h>
#include <set>
#include <map>
#include <time.h>

using namespace std;

/* ===================================================================== */
/* Defines/Enums/Structs */
/* ===================================================================== */

#define MAX_TARG_ADDRS 0x3
#define JUMP_COUNT_THRESHOLD            512
#define PERCENTAGE_OF_JUMPS_THRESHOLD   50

typedef enum {
    RegularIns      = 0,
    RtnHeadIns      = 1,
    TerminatingIns  = 2,
    ProfilingIns    = 3,
    OptimizationIns = 4,
} ins_enum_t;

typedef struct {
    ADDRINT orig_ins_addr;
    ADDRINT new_ins_addr;
    ADDRINT orig_targ_addr;
    ins_enum_t ins_type;
    char encoded_ins[XED_MAX_INSTRUCTION_BYTES];
    unsigned int size;
    int targ_map_entry;
    unsigned bbl_num;
    xed_category_enum_t xed_category;
} instr_map_t;

typedef struct {
    UINT64 counter;
    UINT64 fallthru_counter; // for BBLs that terminate with a cond branch.
    ADDRINT targ_addr[MAX_TARG_ADDRS+1];
    UINT64  targ_count[MAX_TARG_ADDRS+1];
    unsigned starting_ins_entry;
    unsigned terminating_ins_entry;
    bool is_indirect;
} bbl_map_t;


/* ============================================ */
/* Service dump routines                        */
/* ============================================ */
void dump_image_instrs(IMG img);
void dump_instr_from_xedd(xed_decoded_inst_t* xedd, ADDRINT address);
void dump_instr_from_mem(ADDRINT *address, ADDRINT new_addr);
void dump_entire_instr_map_with_prof();
void dump_entire_bbl_map();
void dump_instr_map_entry(unsigned instr_map_entry);
void dump_tc(char *tc, unsigned size_tc);

/* ============================================ */
/* Service translation routines                 */
/* ============================================ */
bool isJumpOrRetOrCall(INS ins);
bool isIndirectJumpOrCall(xed_category_enum_t category, xed_iclass_enum_t jump_iclass);
bool isBackwardJump(INS ins);
REG getKilledRegByIns(INS ins);
int encode_nop_instr(ADDRINT pc, char *encoded_nop_ins);
int encode_jump_instr(ADDRINT pc, ADDRINT target_addr, char *encoded_jmp_ins);
int encode_reverse_cond_jump(char* encoded_ins, char* encoded_rcond_jump_ins, ADDRINT curr_addr, ADDRINT targ_addr);
static inline bool check_precentage_of_jumps(int total_jumps, int target_jumps);
bool is_valid_for_de_virtualization(int bbl_num, unsigned int* hot_target);

/* ============================================ */
/* Optimization code routines                   */
/* ============================================ */
int add_optimization_code_to_tc2(unsigned num_of_instr_map_entries);
int add_optimization_instr(ADDRINT ins_addr, xed_encoder_instruction_t *enc_instr, int instr_map_entry);
int replace_instr_entry(xed_decoded_inst_t *xedd, ADDRINT pc, ins_enum_t ins_type, int instr_map_entry);
int replace_instr_entry_with_new_jump(ADDRINT fallthrough_pc, ADDRINT target_pc, int instr_map_entry_idx, xed_iclass_enum_t jump_iclass, unsigned bbl_num, int target_entry_idx);

/* ============================================ */
/* Translation routines                         */
/* ============================================ */
int disable_profiling_in_tc(instr_map_t * instr_map, unsigned num_of_instr_map_entries);
int add_new_instr_entry(xed_decoded_inst_t *xedd, ADDRINT pc, ins_enum_t ins_type);
int add_prof_instr(ADDRINT ins_addr, xed_encoder_instruction_t *enc_instr);
int add_profiling_instrs(INS ins, ADDRINT ins_addr, UINT64 *counter_addr, unsigned bbl_num);
int add_profiling_instrs_direct_control_flow(INS ins, ADDRINT ins_addr, UINT64 *counter_addr);
void chain_all_direct_br_and_call_target_entries(unsigned from_entry, unsigned until_entry);
void set_initial_estimated_new_ins_addrs_in_tc(char *tc);
int fix_rip_displacement(int instr_map_entry);
int fix_direct_br_call_to_orig_addr(int instr_map_entry);
int fix_direct_br_or_call_displacement(int instr_map_entry);
int fix_instructions_displacements();
int create_tc(IMG img);
int copy_instrs_to_tc(char *tc);
inline void commit_translated_rtns_to_tc();
int commit_translated_rtns_to_tc2();
void create_tc2_thread_func(void *v);
int allocate_and_init_memory(IMG img);

/* ============================================ */
/* Fini                                         */
/* ============================================ */
VOID Fini(INT32 code, VOID* v);
VOID ExitInProbeMode(INT code);

/* ============================================ */
/* Main translation routine                     */
/* ============================================ */
VOID ImageLoad(IMG img, VOID *v);

/* ============================================ */
/* Print Help Message                           */
/* ============================================ */
INT32 Usage();

/* ============================================ */
/* Main                                         */
/* =============================================*/
int main(int argc, char * argv[]);

#endif // PROJECT_H