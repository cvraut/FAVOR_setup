# FAVOR notes

So this is a database of  all possible SNVs (8,812,917,339 SNVs) and observed INDELs (79,997,898 indels) across the human genome (as discovered by TopMed).
- 8,892,915,237 variants total (v2.0)
- 160 possible annotations ([described in documentation tab](http://favor.genohub.org/))

I have downloaded the FAVOR_2.0 full database and modified the example processing scripts to facilitate use with those files.
- Step 0: create the conda env (only do for the first time)
  - TODO: add env files
  - TODO: add setup code
- Step 1: activate the `FAVOR` conda env
  - `$ conda activate FAVOR`


time xsv join --left VarInfo ./chr22/VarInfo_chr22_1.csv variant_vcf ./FAVOR/chr22_1.csv > xsv_test_join.csv
time xsv slice 

# dev notes
- installation of the csv tables took:
```
real    1059m48.468s
user    551m17.277s
sys     247m12.138s
```
