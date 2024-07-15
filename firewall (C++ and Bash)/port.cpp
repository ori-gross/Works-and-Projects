#include "port.h"

#define MAX_PORT_VALUE 65535

using namespace std;

enum { UNDECLARED = 0, SRC = 1, DST = 2 };

Port::Port() : port_type(UNDECLARED),
               min_valid_port(0), max_valid_port(MAX_PORT_VALUE) {}
Port::Port(int type) : port_type(type),
               min_valid_port(0), max_valid_port(MAX_PORT_VALUE) {}
Port::Port(const Port &port) : port_type(port.port_type),
                               min_valid_port(port.min_valid_port),
                               max_valid_port(port.max_valid_port) {}
Port::~Port() {}

bool Port::match(String packet) {
    if (packet.equals(nullptr))
        return false;
    if (this->port_type != SRC && this->port_type != DST)
        return false;
    // Filter the needed information
    const char* packet_delimiters = "=,";
    String* packet_splited_output = nullptr;
    size_t packet_splited_size = 0;
    packet.split(packet_delimiters,
                 &packet_splited_output,
                 &packet_splited_size);
    size_t i = 0;
    String packet_trimmed;
    String packet_port_str;
    // If this is src-port
    if(this->port_type == SRC) {
        const char *src_port = "src-port";
        do {
            packet_trimmed = packet_splited_output[i].trim();
            i++;
        } while((!(packet_trimmed.equals(src_port))) &&
                (i < packet_splited_size));
        if(i == packet_splited_size) {
            delete[] packet_splited_output;
            return false;
        }
        packet_port_str = packet_splited_output[i].trim();
    }
    // If this is dst-port
    else {
        const char *dst_port = "dst-port";
        do {
            packet_trimmed = packet_splited_output[i].trim();
            i++;
        } while((!(packet_trimmed.equals(dst_port))) &&
                (i < packet_splited_size));
        if(i == packet_splited_size) {
            delete[] packet_splited_output;
            return false;
        }
        packet_port_str = packet_splited_output[i].trim();
    }
    delete[] packet_splited_output;
    unsigned short packet_port = packet_port_str.to_integer();
    // Check if the packet port is in the valid range
    if(packet_port < this->min_valid_port || packet_port > this->max_valid_port)
        return false;
    return true;
}

bool Port::set_value(String value) {
    if(value.equals(nullptr))
        return false;
    // Find the port range (min and max) 
    const char* delimiters_hyphen = "-";
    String* port_range_output = nullptr;
    size_t port_range_output_size = 0;
    value.split(delimiters_hyphen, &port_range_output, &port_range_output_size);
    unsigned short port_min_range = port_range_output[0].to_integer();
    unsigned short port_max_range = port_range_output[1].to_integer();
    delete[] port_range_output;
    // Check that the value are valid
    if(port_max_range < 0 || port_max_range > MAX_PORT_VALUE)
        return false; 
    if(!(port_min_range <= port_max_range))
        return false;
    // Return the valid range of the port
    this->min_valid_port = port_min_range;
    this->max_valid_port = port_max_range;
    return true;
}
