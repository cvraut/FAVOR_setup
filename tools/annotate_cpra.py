# This python function takes in a list of chr, pos, ref, alt (cpra) as standard input
# Either comma or "\t" seperated. With or without a header row.
# Each line is supposed to represent a variant in Hg38 (use liftover for other refs).
# Output is written to stdout in the form of a csv.
# Note: If a variant with earlier start position than in DB is specified, that variant will be ignored.
# Variants will be annotated by order encountered in DB not order specified.

import argparse
import sys
import pandas as pd
from collections import defaultdict
from bisect import bisect_right

# Create an argument parser and add the necessary arguments
parser = argparse.ArgumentParser(description='Annotate Variants via FAVOR. \nVariants are passed in line-by-line through stdin. \nEx: `python annotate_cpra.py -s="," < variants.csv > output.csv`')
parser.add_argument('--sep', '-s', type=str, default=None, help='The separator to use (default: any whitespace)')
parser.add_argument('--noheader', '-n', action='store_true', help='Do not include a header row')
parser.add_argument('--debug', '-d', action='store_true', help='Run in debug mode (default: not debug mode)')

# Parse the command line arguments
args = parser.parse_args()

# Use the parsed arguments in your code
sep = args.sep
noheader = args.noheader
DEBUG = args.debug

# Store a couple global variables
FAVOR_LOC = "/mnt/speliotes-lab/Software/FAVOR/"
chrsplit_csv = pd.read_csv("{}tools/FAVORdatabase_chrsplit.csv".format(FAVOR_LOC))

# build a database lookup table
chr_2_fileno_lookup_table = defaultdict(list)
for chrom,fno,sp in zip(chrsplit_csv.Chr,chrsplit_csv.File_No,chrsplit_csv.Start_Pos):
  chr_2_fileno_lookup_table[chrom].append((sp,fno))

# build wrapper function for quick mapping from chrom,pos --> reference file
def get_table_file(c,p):
  i = bisect_right(chr_2_fileno_lookup_table[c],(p,99))
  if i == 0:
    return None
  else:
    i-=1
  _,fno = chr_2_fileno_lookup_table[c][i]
  return "{}annotation_csvs/chr{}_{}.csv".format(FAVOR_LOC,c,fno)

# read in user info and assemble into file & process list
not_in_db = set()
table_file_2_vars = defaultdict(set)
for i,line in enumerate(sys.stdin):
  if i != 0 or noheader:
    c,p,r,a = line.strip().split(sep)
    tbl_file = get_table_file(int(c),int(p))
    if tbl_file:
      table_file_2_vars[tbl_file].add("{}-{}-{}-{}".format(c,p,r,a))
    else:
      not_in_db.add("{}-{}-{}-{}".format(c,p,r,a))
if DEBUG:
  sys.stderr.write("{} variants out of DB positional range.\n".format(len(not_in_db)))

# get var identifier from annotation db
def get_var_identifier(s):
  start_index = s.find(',') + 1
  end_index = s.find(',', start_index)
  return s[start_index:end_index]

# process the table_file
def process_tbl(tbl_file):
  with open(tbl_file,"r") as f:
    for i,line in enumerate(f):
      if i != 0:
        vid = get_var_identifier(line)
        if vid in table_file_2_vars[tbl_file]:
          print("{},{}".format(vid,line),end="")

# print output header
def get_header(tbl_file):
  with open(tbl_file,"r") as f:
    for line in f:
      print("VarInfo,{}".format(line),end="")
      return

# print the header
for filename in table_file_2_vars:
  get_header(filename)
  break

# run iteratively
for filename in table_file_2_vars:
  if DEBUG:
    sys.stderr.write("Processing {}. For {} variants.\n".format(filename,len(table_file_2_vars[filename])))
  process_tbl(filename)