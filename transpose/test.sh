#!/bin/bash

make_csv() {
    # Create XXXsepYYY.csv (XXX rows, YYY cols, sep as separator)
    normal() {
	perl -e '($m,$sep,$n) = $ARGV[0]=~/(\d+)(\D+)(\d+)/; $sep = eval "\"$sep\""; for $l (1..$m){ print join $sep, map {"$_-$l"} (1..$n); print "\n" }' $@ > $@
    }
    transposed() {
	perl -e '($m,$sep,$n) = $ARGV[0]=~/(\d+)(\D+)(\d+)/; $sep = eval "\"$sep\""; for $l (1..$n){ print join $sep, map {"$l-$_"} (1..$m); print "\n" }' $@ > $@.t
    }
    export -f normal transposed
    parallel -q {} "$@" ::: normal transposed
}

md5transpose() {
    local file
    file=$1
    blk="$2 $3"
    echo File $file
    transpose $blk -d "$(echo "$file" | perl -pe 's/.*\d(\D+)\d.*/$1/')" $file | md5sum
    cat $file |
	transpose $blk -d "$(echo "$file" | perl -pe 's/.*\d(\D+)\d.*/$1/')" | md5sum
    cat $file.t | md5sum

    transpose $blk -d "$(echo "$file" | perl -pe 's/.*\d(\D+)\d.*/$1/')" $file.t | md5sum
    cat $file.t |
	transpose $blk -d "$(echo "$file" | perl -pe 's/.*\d(\D+)\d.*/$1/')" | md5sum
    cat $file | md5sum
}

dotest() {
    if [ ! -e "$1".t ] ; then
	make_csv "$1"
    fi
    md5transpose "$@"
    echo
}

. `which env_parallel.bash`
env_parallel -r <<'EOF'
dotest /tmp/table-3,1000000.csv
dotest /tmp/table-3,10000000.csv
dotest /tmp/table-1000,100000.csv
# Test --block 1 (problem with GNU Parallel < 20180422)
dotest /tmp/table-3,1000.csv -b 1
dotest /tmp/table-3\|1000.csv
dotest /tmp/table-3,1000.csv
dotest /tmp/table-3,10000.csv
dotest /tmp/table-3,100000.csv

dotest '/tmp/table-10\t20.csv'
dotest /tmp/table-10';'20.csv
dotest '/tmp/table-100\t200.csv'
dotest /tmp/table-1,100.csv
dotest /tmp/table-10,1000.csv
dotest /tmp/table-100,10000.csv
EOF
