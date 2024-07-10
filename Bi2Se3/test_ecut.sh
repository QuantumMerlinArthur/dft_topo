#!/bin/bash

# Assuming naming convention as follows:
# name_of_simulation.in as input file, e.g., "si.cd.scf" without '.in'

# Parse command line arguments
if [ $# -lt 1 ]; then
    echo "Usage: $0 <simulation_name> [ECUT1 ECUT2 ECUT3 ...]"
    exit 1
fi

name="$1"
curdir=$(pwd)
datfile="$curdir/$name.ecut.dat"
infile="$curdir/$name.in"
outfile="$curdir/$name.out"

# Set default ECUT values
ecut_values=(30 90 120 )

# Check if custom ECUT values are provided
if [ $# -gt 1 ]; then
    shift # Remove the first argument (simulation name)
    ecut_values=("$@")
fi


if ! [ -f "$datfile" ]; then
echo -e "ecut\tetot" > "$datfile" # header
done
echo -e "ecut\tetot" # print out

# Loop through ecut values
for ECUT in "${ecut_values[@]}"; do
    let ECUTrho="2*ECUT" # default is 4*ecutwfc
    sed -i "/ecutwfc/s/=.*/= $ECUT/" "$infile" # replace ecut value in .in file
    # sed -i "/ecutrho/s/=.*/= $ECUTrho/" "$infile"
    mpirun -np 8 pw.x -i "$infile" > "$outfile" # run in parallel on 8 kernels

    # Grep the total energy of the last iteration
    etot=$(grep "total energy" "$outfile" | tail -2 | head -1 | awk '{split($0,a," "); print a[5]}')
    echo -e "$ECUT\t$etot" # print out
    echo -e "$ECUT\t$etot" >> "$datfile" # save to file
done
