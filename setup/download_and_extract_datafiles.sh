urls_file=~/wkspce/FAVOR_setup/csv_urls.txt

cd ~/wkspce/FAVOR_setup/FAVOR/

while read -r url || [ -n "$url" ]; do # Read exits with 1 when done; -r allows \
  echo -E "$url"                         # -E allows printing of \ instead of gibberish
  filename=$(basename $url)
  wget $url
  echo -E $filename
  tar -xzvf $filename

done < ${urls_file} 

pwd

# this took 1000 minutes to run