echo $1

# look for changed directories
cd api-connectors
ARRAY=()
for file in $1
do
    echo changed_file:$file
    filename="$(basename -- $file)"
    extension="${filename##*.}"
    parentdir=$(echo "$file" | cut -d "/" -f2)
    echo parent_dir:${parentdir}
    ARRAY+=(${parentdir})
done

# make changed directories unique in case of running the same tests many times
uniquedirs=($(for v in "${ARRAY[@]}"; do echo "$v";done| sort| uniq| xargs))
echo changed_dirs:"${uniquedirs[@]}"

# get config folder under repo (e.g. twitter, yelp)
dirs=()
echo $PWD
for dirname in $(find ${PWD} -maxdepth 1 -type d -not -path '*/\.*')
do
    result="${dirname%"${dirname##*[!/]}"}"
    result="${result##*/}"
    echo dirs_under_root:"${result}"
    dirs+=(${result})
done

# run all tests inside impacted config folder
for dir in "${uniquedirs[@]}"
do
    echo $dir
    if [[ " ${dirs[@]} " =~ " ${dir} " ]]; then
        for testfile in ./${dir}/*/tests/*
        # for testfile in ./*/tests/*
        do
            echo testfile:"$testfile"
            pytest $testfile
        done
    fi  
done

