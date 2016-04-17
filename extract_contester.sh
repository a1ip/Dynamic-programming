#!/bin/bash
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
find . -type f -exec iconv -f windows-1251 -t utf-8 {} -o {} \; 2>/dev/null
checker=$(ls ${pname}?checker* 2>/dev/null | sort -r | head -1)
solver=$(ls ${pname}?solver* 2>/dev/null | sort -r | head -1)
statement=$(ls ${pname}*.htm* 2>/dev/null | sort -r | head -1)
ntests=$(ls tests/*_input.txt 2>/dev/null | wc -l)

cp "$checker" "$rt/checker.${checker##*.}" 2>/dev/null
cp "$solver" "$rt/solver.${solver##*.}" 2>/dev/null
cp "$statement" "$rt/statement.${statement##*.}" 2>/dev/null
cp -r "tests" "$rt/tests" 2>/dev/null

pushd "$rt/tests" > /dev/null 2>&1

rename "${pname}_" "" * 2>/dev/null
rename "_input.txt" ".input" * 2>/dev/null
rename "_pattern.txt" ".pattern" * 2>/dev/null

rename "${pname}-" "" * 2>/dev/null
rename "-input.txt" ".input" * 2>/dev/null
rename "-pattern.txt" ".pattern" * 2>/dev/null

popd > /dev/null 2>&1

timelimit=$(sed -n "s/^ *<TimeLimit platform=\"native\">\([0-9]\+\)<\/TimeLimit>/\1/p" < ${pname}.xml)
memlimit=$(sed -n "s/^ *<MemoryLimit platform=\"native\">\([0-9]\+\)<\/MemoryLimit>/\1/p" < ${pname}.xml)
problemname=$(sed -n "s/^ *<Name lang=\"ru\">\(.*\)<\/Name>/\1/p" < ${pname}.xml)

echo "timelimit=\"$timelimit\"" >> "$rt/meta"
echo "memlimit=\"$timelimit\"" >> "$rt/meta"
echo "name=\"$problemname\"" >> "$rt/meta"
echo "ntests=\"$ntests\"" >> "$rt/meta"

popd > /dev/null 2>&1

rm -rf "/tmp/$pname"
