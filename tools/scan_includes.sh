#!/bin/bash
function includes() { IFS=$'\n'; for file in $(sed -n 's/^INCLUDE "\(.*\)"$/\1/p' $1); do echo "$file"; includes $file; done ; }

for file in "$@"; do includes "$file"; done
