#!/bin/bash

doit() {
    opt="$1"
    file="$2"
    sudo tracefile $opt dd if=/dev/zero of="$file" bs=1000k count=10
    sudo tracefile $opt chmod 600 $file
    sudo tracefile $opt mkswap $file
    sudo tracefile $opt swapon $file
    sudo tracefile $opt swapoff $file
    sudo rm "$file"
}
export -f doit

# Test 2 char dir
mkdir -p tt/tt
parallel -vj1 doit \
	 ::: '' -l -u \
	 ::: tt/tt/../tt/test.img `pwd`/tt/tt/../tt/test.img | grep test.img
