#!/bin/env python
# -*- coding: utf-8 -*-
## finviz ##

import sys, csv, argparse, sqlite3

fields = ["No.","Ticker","Company","Sector","Industry","Country","Market Cap","P/E","Price","Change","Volume"]
formated_fields = [a.replace('.', '_').replace('/', '_').replace(' ', '_') for a in fields]

def comma_reduce(stringlist):
    return reduce(lambda a, b: '{0}, {1}'.format(a, b),
                  stringlist)

def make_parser():
    """\brief return prepared parser
    """
    parser = argparse.ArgumentParser()
    parser.add_argument('-o', '--output', type=argparse.FileType('w'), help='File name to print output result, if not set result will be printed to stdout')
    parser.add_argument('-n', '--no-clean', action='store_true', help='Result is CSV file, if not set result is just list of tickets')
    parser.add_argument('-j', '--join', action='store_true', help='Result is the join of several files')
    parser.add_argument('-i', '--intersect', action='store_true', help='Result is the intersection of several files')
    parser.add_argument('-u', '--unique', action='store_true', help='Result is the unique elements of each file')
    parser.add_argument('-s', '--substract', action='store_true', help='Result is the substract the remaining files from the first')
    parser.add_argument('files', nargs='+', type=file)
    return parser

def check_args(parser, res):
    """\brief check arguments if the are correct
    \param parser
    \param res
    """
    if len(res.files) > 1 and not (res.join or res.intersect or res.unique or res.substract):
        sys.stderr.write(parser.format_usage())
        sys.stderr.write('You must specify one of processing options -j, -i, -u or -s\n')
        exit(1)
        
    prc = 0
    for proc in [res.join, res.intersect, res.unique, res.substract]:
        if proc:
            prc += 1
    if prc > 1:
        sys.stderr.write(parser.format_usage())
        sys.stderr.write('You must specify no more that one option -j, -i, -u or -s\n')
        exit(1)

def create_tables(db):
    """\brief create tables to import data in
    \param db
    """
    db.execute('pragma foreign_keys=on') # turn on foreign keys
    db.execute('create table files(id int, unique(id))')
    db.execute('create table stocks(file_id, {0}, foreign key (file_id) references files(id), unique(file_id, Ticker))'.format(comma_reduce(formated_fields[1:])))

def fill_db(db, res):
    """\brief fill database with data
    \param db
    \param res
    """
    for infile in res.files:
        db.execute('insert into files(id) values (?)', [infile.fileno()])
        csvreader = csv.reader(infile)
        header = csvreader.next()       # read first string
        if set(header) != set(fields):
            sys.stderr.write('File {0} has wrong format\n'.format(infile.name))
            exit(1)
        indexes = {}
        for f in fields:
            indexes[f] = header.index(f)
        query = 'insert into stocks(file_id, {0}) values ({1})'.format(comma_reduce(formated_fields[1:]),
                                                                       comma_reduce(['?' for x in formated_fields[1:]] + ['?']))
        print(query)
        for stock in csvreader:
            flds = []
            for f in [stock[indexes[field_name]] for field_name in fields[1:]]:
                try:
                    flds.append(int(f))
                except:
                    try:
                        flds.append(float(f))
                    except:
                        flds.append(f)
            db.execute(query, [infile.fileno()] + flds)
            
def print_join(outf, db, res):
    """\brief print join result to outf, get data from db considering res
    \param outf
    \param db
    \param res
    """
    if res.no_clean:
        writer = csv.writer(outf, delimiter = ',', doublequote=True, quoting=csv.QUOTE_NONNUMERIC)
        writer.writerow(fields)         # write header
        number = 1
        for flds in db.execute('select distinct {0} from stocks'.format(comma_reduce(formated_fields[1:]))):
            writer.writerow([number] + list(flds))
            number += 1
    else:
        for (ticker, ) in db.execute('select distinct Ticker from stocks order by Ticker'):
            outf.write('{0}\n'.format(ticker))
    

def print_intersect(outf, db, res):
    """\brief print intersect result to outf
    \param outf
    \param db
    \param res
    """
    if res.no_clean:
        writer = csv.writer(outf, delimiter = ',', doublequote=True, quoting=csv.QUOTE_NONNUMERIC)
        writer.writerow(fields)         # write header
        number = 1
        for flds in db.execute('select distinct {0} from stocks'.format(comma_reduce(formated_fields[1:]))):
            writer.writerow([number] + list(flds))
            number += 1
    else:
        for (ticker, ) in db.execute('select distinct Ticker from stocks order by Ticker'):
            outf.write('{0}\n'.format(ticker))
    

def print_unique(outf, db, res):
    """\brief print result of 'unique' to outf
    \param outf
    \param db
    \param res
    """
    pass

def print_substract(outf, db, res):
    """\brief print result of substraction to outf
    \param outf
    \param db
    \param res
    """
    pass

def print_usually(outf, db, res):
    """\brief print all data from db to outf considering res
    \param outf
    \param db
    \param res
    """
    if res.no_clean:
        writer = csv.writer(outf, delimiter = ',', doublequote=True, quoting=csv.QUOTE_NONNUMERIC)
        writer.writerow(fields)         # write header
        number = 1
        for flds in db.execute('select {0} from stocks'.format(comma_reduce(formated_fields[1:]))):
            writer.writerow([number] + list(flds))
            number += 1
    else:
        for (ticker, ) in db.execute('select Ticker from stocks order by Ticker'):
            outf.write('{0}\n'.format(ticker))

def proceed(res):
    """\brief proceed processing
    \param res
    """
    db = sqlite3.connect(':memory:')
    create_tables(db)
    fill_db(db, res)
    outf = sys.stdout
    if res.output != None:
        outf = res.output

    if res.join:
        print_join(outf, db, res)
    elif res.intersect:
        print_intersect(outf, db, res)
    elif res.unique:
        print_unique(outf, db, res)
    elif res.substract:
        print_substract(outf, db, res)
    else:
        print_usually(outf, db, res)

def work(args):
    """\brief do the main work
    \param args
    """
    parser = make_parser()
    try:
        res = parser.parse_args(args)
    except Exception as e:
        sys.stderr.write(parser.format_usage())
        sys.stderr.write(str(e))
        exit(1)
    check_args(parser, res)
    proceed(res)


if __name__ == '__main__':
    
    work(sys.argv[1:])
