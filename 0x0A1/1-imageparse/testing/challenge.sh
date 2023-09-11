#!/bin/bash

filename=$1
imagetype=$2

cat "$filename" | grep -o "https://[^\"]*\.$imagetype"
