#!/bin/sh

echo "Cleaning all prior tests."
rm -fr logs/fox logs/seal* figures/fox* figures/seal*
mkdir -p logs/debugging logs/matlab