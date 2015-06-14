#!/bin/bash

main-scripts/concat.sh ../data/baby-stool-individuals-09202013/ ../data/processed
echo "Concat done"

main-scripts/map.sh lists/elist 2> err.log | tee out.log
echo "Mapping done"

main-scripts/summary.py lists/elist keys/babykey1.csv
echo "Summary done"

main-scripts/run-cuffdiff.py lists/elist keys/babykey2.csv
echo "Comparison done"