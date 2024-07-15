#!/bin/bash

# Gets complex rules file struct
complex_rules_file=$(cat "$1")

# Remove '#' (comments) and empty lines
filtered_complex_rules_file=$(echo "$complex_rules_file" |
                              sed '/^#/d;/^$/d' | sed 's/\([^#]*\)#.*/\1/')

# Gets packets
packets=""
while read -r line; do
    packets+="$line"$'\n'
done

valid_packets=""
# Scanning each complex rule struct
while read -r complex_rule; do
    valid_complex_rule_packets="$packets"
    Delimiter=',' read -ra rule <<< "${complex_rule//,/ }"
    # Scanning each rule with firewall.exe
    for rule in "${rule[@]}"; do
        valid_complex_rule_packets=$(echo "$valid_complex_rule_packets" |
                                     ./firewall.exe "$rule")
    done
    valid_packets+=$'\n'$(echo "$valid_complex_rule_packets" |
                          ./firewall.exe "$rule")
done <<< "$filtered_complex_rules_file"

# Prints the valid packets
valid_packets=$(echo "$valid_packets" | sort | uniq |
                sed '/^$/d' | sed -e 's/[[:space:]]//g')
echo "$valid_packets"