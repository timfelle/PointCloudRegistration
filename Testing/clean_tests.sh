#!/bin/sh

echo "Cleaning all prior tests and importing figures from cluster."
rm -fr logs figures
mkdir -p logs/debugging
./fetch_figures.sh