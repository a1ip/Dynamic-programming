#!/bin/bash
set -e
if [[ -z $1 ]]; then
    echo "Usage: $0 <contester zip>"
    exit 1
fi

zipname=$1
basezipname=$(basename $zipname)
pname=$(echo "$basezipname" | sed 's/^problemzipdownload-pid-[0-9a-f]\{4\}-[0-9a-f]\{3\}[_-]\(.*\)\.zip$/\1/')

rt="$(pwd)/$pname"

rm -rf "/tmp/$pname"
mkdir -p "/tmp/$pname"
rm -rf "$rt"
mkdir -p "$rt"
pushd "/tmp/$pname" > /dev/null 2>&1

unzip "$rt/../$zipname" > /dev/null 2>&1
find . -type f -exec iconv -f windows-1251 -t utf-8 {} -o {} \;
checker=$(ls ${pname}_checker* | sort -r | head -1)
solver=$(ls ${pname}_solver* | sort -r | head -1)
statement=$(ls ${pname}*.htm* | sort -r | head -1)
ntests=$(ls tests/*_input.txt | wc -l)

cp "$checker" "$rt/checker.${checker##*.}"
cp "$solver" "$rt/solver.${solver##*.}"
cp "$statement" "$rt/statement.${statement##*.}"
cp -r "tests" "$rt/tests"

pushd "$rt/tests" > /dev/null 2>&1

rename "${pname}_" "" *
rename "_input.txt" ".input" *
rename "_pattern.txt" ".pattern" *

popd > /dev/null 2>&1

timelimit=$(sed -n "s/^ *<TimeLimit platform=\"native\">\([0-9]\+\)<\/TimeLimit>/\1/p" < palindroms.xml)
memlimit=$(sed -n "s/^ *<MemoryLimit platform=\"native\">\([0-9]\+\)<\/MemoryLimit>/\1/p" < palindroms.xml)
problemname=$(sed -n "s/^ *<Name lang=\"ru\">\(.*\)<\/Name>/\1/p" < palindroms.xml)

echo "timelimit=$timelimit" >> "$rt/meta"
echo "memlimit=$timelimit" >> "$rt/meta"
echo "name=$problemname" >> "$rt/meta"
echo "ntests=$ntests" >> "$rt/meta"

popd > /dev/null 2>&1

rm -rf "/tmp/$pname"
