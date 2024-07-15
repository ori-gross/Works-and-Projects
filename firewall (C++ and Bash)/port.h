#ifndef PORT_H
#define PORT_H

#include "generic-field.h"

class Port : public GenericField {
    int port_type;
    unsigned short min_valid_port;
    unsigned short max_valid_port;
public:
    Port();
    Port(int type);
    Port(const Port &port);
    ~Port();
    bool match(String packet);
    bool set_value(String value);
};

#endif
