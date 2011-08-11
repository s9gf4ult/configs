#!/bin/env python

from lxml import etree
import sys

def print_help():
    print("""usage:
   format_xml input_file output_file
   format_xml input_file""")

if __name__ == '__main__':
    args = sys.argv[1:]
    if len(args) not in [1, 2]:
        print_help()
        exit(1)
    x = etree.parse(args[0])
    with open(args[-1], 'w') as outf:
        outf.write(etree.tostring(x, encoding='utf-8', xml_declaration = True, pretty_print = True))
    exit(0)
