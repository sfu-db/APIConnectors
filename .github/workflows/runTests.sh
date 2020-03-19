echo $PWD
for file in $1
do
        echo $file
        filename="$(basename -- $file)"
        extension="${filename##*.}"
        parentdir="$(basename "$(dirname "$file")")"
        echo parent_dir:${parentdir}
        if [[ "$parentdir" =~ ^(dblp|spotify|twitter|yelp)$ ]]; then
            for testfile in ./${parentdir}/tests/*:
            do
                echo testfile:"$testfile"
                poetry run pytest $testfile
            done
        fi  
        # name="${filename%.*}"
        # test_file_name=./dataprep/tests/${parentdir}/${name}_test.py
        # echo ${test_file_name}
        # poetry run pytest ${test_file_name}
        
done
# poetry run pytest ./dataprep/tests/eda/test.py
# poetry run pytest ./dataprep/tests/eda/test_plot.py
# poetry run pytest ./dataprep/tests/eda/test_plot_correlation.py
# poetry run pytest ./dataprep/tests/eda/test_plot_missing.py

