#include "ip.h"

#define SIZE_OF_BYTE 8
#define MAX_BYTE_VALUE 255
#define IP_BITS_NUM 32

using namespace std;

enum { UNDECLARED = 0, SRC = 1, DST = 2 };

IP::IP() : ip_type(UNDECLARED), mask(String()), ip_value(0),
           num_of_bits(IP_BITS_NUM) {}
IP::IP(int type) : ip_type(type), mask(String()), ip_value(0),
                   num_of_bits(IP_BITS_NUM) {}
IP::IP(const IP &ip) : ip_type(ip.ip_type), mask(String(ip.mask)), 
                       ip_value(ip.ip_value), num_of_bits(ip.num_of_bits) {}
IP::~IP() {}

bool IP::match(String packet) {
    if (packet.equals(nullptr))
        return false;
    if (this->ip_type != SRC && this->ip_type != DST)
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
    String packet_ip_str;
    // If this is src-ip
    if(this->ip_type == SRC) {
        const char *src_ip = "src-ip";
        do {
            packet_trimmed = packet_splited_output[i].trim();
            i++;
        } while((!(packet_trimmed.equals(src_ip))) &&
                (i < packet_splited_size));
        if(i == packet_splited_size) {
            delete[] packet_splited_output;
            return false;
        }
        packet_ip_str = packet_splited_output[i].trim();
    }
    // If this is dst-ip
    else {
        const char *dst_ip = "dst-ip";
        do {
            packet_trimmed = packet_splited_output[i].trim();
            i++;
        } while((!(packet_trimmed.equals(dst_ip))) &&
                (i < packet_splited_size));
        if(i == packet_splited_size) {
            delete[] packet_splited_output;
            return false;
        }
        packet_ip_str = packet_splited_output[i].trim();
    }
    delete[] packet_splited_output;
    // Filter between the numbers in the ip to the periods
    const char* delimiters_period = ".";
    String* ip_output_number = nullptr;
    size_t ip_output_number_size = 0;
    packet_ip_str.split(delimiters_period,
                        &ip_output_number,
                        &ip_output_number_size);
    // Convert to int and combine between the 4 strings that represent the 
    // ip, in the end we will have one int with 32 bits.                       
    size_t packet_ip = 0;
    for(i=0; i<ip_output_number_size; i++) {
        int curr_byte = ip_output_number[i].to_integer();
        // Check that the values are valid
        if(curr_byte < 0 || curr_byte > MAX_BYTE_VALUE) {
            delete[] ip_output_number;
            return false;
        }
        curr_byte = curr_byte << SIZE_OF_BYTE*(ip_output_number_size-i-1);
        packet_ip = packet_ip | curr_byte;
    }
    delete[] ip_output_number;
    // Set the packet ip according to the set value
    packet_ip =  packet_ip >> (IP_BITS_NUM-this->num_of_bits);
    // Check if the packet ip match to the set value
    if (packet_ip == this->ip_value)
        return true;
    return false;
}

bool IP::set_value(String value) {
    if(value.equals(nullptr))
        return false;
    this->mask.operator=(value);
    //Find the ip and the relevant ip's bites according to the mask
    const char* delimiters_slash = "/";
    String* ip_output_mask = nullptr;
    size_t ip_output_size_mask = 0;
    mask.split(delimiters_slash, &ip_output_mask, &ip_output_size_mask);
    String ip_mask = ip_output_mask[0];
    int num_of_bits_mask = ip_output_mask[1].to_integer();
    delete[] ip_output_mask;
    // Check that the value are valid
    if(num_of_bits_mask < 0 || num_of_bits_mask > IP_BITS_NUM)
        return false;
    this->num_of_bits = num_of_bits_mask;
    // Filter between the numbers in the ip to the periods
    const char* delimiters_period = ".";
    String* ip_output_number_mask = nullptr;
    size_t ip_output_number_mask_size = 0;
    ip_mask.split(delimiters_period, &ip_output_number_mask, 
                  &ip_output_number_mask_size);
    // Convert to int and combine between the 4 strings that represent the 
    // ip, in the end we will have one int with 32 bits.                       
    this->ip_value = 0;
    for(size_t i=0; i<ip_output_number_mask_size; i++) {
        int curr_byte = ip_output_number_mask[i].to_integer();
        // Check that the values are valid
        if(curr_byte < 0 || curr_byte > MAX_BYTE_VALUE) {
            delete[] ip_output_number_mask;
            return false; 
        }
        curr_byte = curr_byte << SIZE_OF_BYTE*(ip_output_number_mask_size-i-1);
        this->ip_value = this->ip_value | curr_byte;
    }
    delete[] ip_output_number_mask;
    // Set the ip according to the set value
    this->ip_value = this->ip_value >> (IP_BITS_NUM - num_of_bits);
    return true;
}
