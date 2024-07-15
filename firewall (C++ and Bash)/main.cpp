#include "input.h"
#include "string.h"
#include "generic-field.h"
#include "ip.h"
#include "port.h"

using namespace std;

enum { UNDECLARED = 0, SRC = 1, DST = 2  };

int main(int argc, char **argv) {
    // Check if the arguments of the method main are valid.
    if(check_args(argc, argv) != 0)
       return 1;
    
    // Find which type is the input ip/port & src/dst
    String input(argv[1]);
    const char* delimiters = "=";
    String* output = nullptr;
    size_t output_size = 0;
    input.split(delimiters, &output, &output_size);
    // String type = "src/dst-ip/port";
    String type = output[0].trim();
    // String rule = the actual src/dst with the mask/range
    String rule = output[1].trim();
    // Run the parse_input to the relevent input
    if (type.equals("src-ip")) {
        IP src_ip(SRC);
        src_ip.set_value(rule);
        parse_input(src_ip);
    }
    else if (type.equals("dst-ip")) {
        IP dst_ip(DST);
        dst_ip.set_value(rule);
        parse_input(dst_ip);
    }
    else if (type.equals("src-port")) {
        Port src_port(SRC);
        src_port.set_value(rule);
        parse_input(src_port);
    }
    else if (type.equals("dst-port")) {
        Port dst_port(DST);
        dst_port.set_value(rule);
        parse_input(dst_port);
    }
    delete[] output;
    return 0;
}
