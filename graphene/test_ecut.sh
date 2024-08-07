#!/bin/bash

# this script assumes naming convention as follows:
# name_of_simulation.in as input file, eg. "si.cub.in"

# request user input
curdir=$(pwd)
echo "current dir: " $curdir
echo "cutoff energy convergence test. Enter name (e.g. si.cd.scf without '.in'): "
read name

datfile="$curdir/$name.ecut.dat"
infile="$curdir/$name.in"
outfile="$curdir/$name.out"

echo -e "ecut\tetot" > "$datfile" # header
echo -e "ecut\tetot" # print out

# loop through ecut values
for ECUT in 40 70 100
do
sed -i "/ecutwfc/s/=.*/= $ECUT/" "$infile" # replace ecut value in .in file

mpirun -np 8 pw.x -i $infile > $outfile # run in parralel on 8 kernels

# grep the total energy of the last iteration
etot=$(grep "total energy" $outfile | tail -2 | head -1 | awk '{split($0,a," "); print a[5]}') 
echo -e "$ECUT\t$etot" # print out
echo -e "$ECUT\t$etot" >> $datfile # save to file
done



