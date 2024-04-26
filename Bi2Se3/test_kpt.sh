#!/bin/bash

# this script assumes naming convention as follows:
# name_of_simulation.in as input file, eg. "si.cub.in"

# request user input
curdir=$(pwd)
echo "current dir: " $curdir
echo "cutoff energy convergence test. Enter name (e.g. si.cd.scf without '.in'): "
read name

datfile="$curdir/$name.kpt.dat"
infile="$curdir/$name.in"
outfile="$curdir/$name.out"
echo -e "k\tetot" > "$datfile" # header


# loop through ecut values
for k in 4 6 8
do
sed -i "/K_POINTS/ {n; s/.*/    $k $k 2 0 0 0/}" "$infile" 

mpirun -np 8 pw.x -inp $infile > $outfile
etot=$(grep "total energy" $outfile | tail -2 | head -1 | awk '{split($0,a," "); print a[5]}') 
echo -e "$k\t$etot"
echo -e "$k\t$etot" >> $datfile
done