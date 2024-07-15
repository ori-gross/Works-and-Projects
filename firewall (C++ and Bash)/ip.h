#ifndef IP_H
#define IP_H

#include "generic-field.h"

class IP : public GenericField {
    int ip_type;
    String mask;
    size_t ip_value;
    int num_of_bits;
public:
    IP();
    IP(int type);
    IP(const IP &ip);
    ~IP();
    bool match(String packet);
    bool set_value(String value);
};

#endif
