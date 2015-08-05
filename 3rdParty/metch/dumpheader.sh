#!/bin/sh
# this script dumps the header info in wiki format from the m-files

head -42 *.m | grep '^[=%]' | grep -v 'Qianqian' | grep -v 'date' | grep -v 'Please find more' \
| grep -v 'this function is ' | sed -e 's/^%//g' | sed -e 's/[<]*==[>]*/===/g' | \
awk '/===$/ {getline t; print $0 "\n<tt>" t "</tt>"; next}; 1'
