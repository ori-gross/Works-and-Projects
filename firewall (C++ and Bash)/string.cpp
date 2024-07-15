#include <cstring>
#include "string.h"

using namespace std;

String::String() : length(1) {
    data = new char[length];
    data[0] = '\0';
}

String::String(const String &str) : length(str.length) {
    data = new char[length];
    strcpy(data, str.data);
}

String::String(const char *str) {
    length = strlen(str)+1;
    data = new char[length];
    strcpy(data, str);
}

String::~String() {
    delete[] data;
}

String& String::operator=(const String &rhs) {
    if(this == &rhs)
        return *this; // Self-assignment check
    delete[] this->data; // Deallocate existing data
    // Copy data from rhs
    this->length = rhs.length;
    this->data = new char[this->length];
    strcpy(this->data, rhs.data);
    return *this;
}

String& String::operator=(const char *str) {
    if(str != nullptr) {
        // Copy data from str
        this->length = strlen(str)+1;
        delete[] this->data;
        this->data = new char[this->length];
        strcpy(this->data, str);
    }
    return *this;
}

bool String::equals(const String &rhs) const {
    if(strcmp(this->data, rhs.data) == 0)
        return true; // The strings are equal
    return false;
}

bool String::equals(const char *rhs) const {
    if(rhs != nullptr) {
        if(strcmp(this->data, rhs) == 0)
            return true; // The strings are equal
    }
    return false;
}

void String::split(const char* delimiters, String** output, size_t* size) const {
    if(size == nullptr)
        return;
    // Create a copy of the string
    char* string_copy = new char[this->length];
    strcpy(string_copy, this->data);
    size_t num_of_tokens = 1;
    char* token = strtok(string_copy, delimiters);
    // Count the number of tokens
    while (token != nullptr) {
        token = strtok(nullptr, delimiters);
        if (token != nullptr)
            num_of_tokens++;
    }
    // Set the output size
    *size = num_of_tokens;
    // If output is null
    if(output == nullptr) {
        delete[] string_copy;
        return;
    }
    *output = new String[*size];
    // Reset the string copy
    strcpy(string_copy, this->data);
    token = strtok(string_copy, delimiters);
    // Copy tokens to the output array
    for(size_t i = 0; i < num_of_tokens; i++) {
        (*output)[i] = token;
        token = strtok(nullptr, delimiters);
    }
    // Free the memory allocated for the string copy
    delete[] string_copy;
}

int String::to_integer() const {
    return atoi(this->data);
}

String String::trim() const {
    // Find the index of the first non-whitespace character
    size_t start_index = 0;
    size_t end_index = this->length - 1;
    while(start_index < this->length-1 && this->data[start_index] == ' ')
        start_index++;
    // Find the index of the last non-whitespace character
    while(end_index > start_index &&
         ((this->data[end_index] == ' ')||(this->data[end_index] == '\0')))
        end_index--;
    size_t trimmed_length = end_index - start_index + 1;
    // Create a new string with the trimmed contents
    char* trimmed_data = new char[trimmed_length + 1];
    //strncpy(trimmed_data, this->data + start_index, trimmed_length);
    for(size_t i = 0; i < trimmed_length; i++) {
        trimmed_data[i] = this->data[start_index+i];
    }
    trimmed_data[trimmed_length] = '\0';
    // Create and return the trimmed String object
    String trimmed_string(trimmed_data);
    // Free the memory allocated for the trimmed data
    delete[] trimmed_data;
    return trimmed_string;
}
