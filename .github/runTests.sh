ARRAY=()
for file in $1
do
    echo changed_files:$file
    filename="$(basename -- $file)"
    extension="${filename##*.}"
    parentdir="$(basename "$(dirname "$file")")"
    echo parent_dir:${parentdir}
    ARRAY+=(${parentdir})
done

uniquedirs=($(for v in "${ARRAY[@]}"; do echo "$v";done| sort| uniq| xargs))
echo changed_dirs:"${uniquedirs[@]}"

dirs=()
echo $PWD
for dirname in $(find ${PWD} -maxdepth 1 -type d -not -path '*/\.*')
do
    result="${dirname%"${dirname##*[!/]}"}"
    result="${result##*/}"
    echo dirs_under_root:"${result}"
    dirs+=(${result})
done

for dir in "${uniquedirs[@]}"
do
    if [[ " ${dirs[@]} " =~ " ${dir} " ]]; then
        for testfile in ./${dir}/tests/*
        do
            echo testfile:"$testfile"
            poetry run pytest $testfile
        done
    fi  
done

