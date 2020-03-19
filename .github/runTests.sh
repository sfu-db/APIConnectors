echo $PWD
for file in $1
do
        echo $file
        filename="$(basename -- $file)"
        extension="${filename##*.}"
        parentdir="$(basename "$(dirname "$file")")"
        echo parent_dir:${parentdir}
        if [[ "$parentdir" =~ ^(dblp|spotify|twitter|yelp)$ ]]; then
            for testfile in ./${parentdir}/tests/*
            do
                echo testfile:"$testfile"
                poetry run pytest $testfile
            done
        fi  
done

