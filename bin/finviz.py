#!/bin/env python
# -*- coding: utf-8 -*-
## finviz ##

import csv
import sys

def print_help():
    print("""usage:
finviz.py file.cvs
or
finviz.py file.cvs outfile.txt""")

def instock(filename):
    """\brief 
    \param filename
    """
    with open(filename, 'r') as infile:
        r = csv.reader(infile)
        first = True
        for line in r:
            if not first:
                yield line[1]
            else:
                first = False
    
if len(sys.argv) == 2:
    infile = sys.argv[1]
    outfile = sys.argv[1]
elif len(sys.argv) == 3:
    infile = sys.argv[1]
    outfile = sys.argv[2]
else:
    print_help()
    exit(1)

ins = ['{0}\n'.format(a) for a in instock(infile)]
with open(outfile, 'w') as outfile:
    outfile.writelines(ins)
