# converts GDS files to aGDS files using the FAVOR database to annotate variants
# this script is messy as it will create auxilliary files, run only in dirs where there is sufficient space
#!/bin/bash

# Set default value for AGDS_FILE
AGDS_FILE=""
script_dir=$(dirname "$0")

# Create an argument parser and add the necessary arguments
while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    -g|--gds_file)
    GDS_FILE="$2"
    shift # past argument
    shift # past value
    ;;
    -a|--agds_file)
    AGDS_FILE="$2"
    shift # past argument
    shift # past value
    ;;
    -h|--help)
    echo "Usage: $0 --gds_file <filename> [--agds_file <filename>]"
    echo ""
    echo "Required arguments:"
    echo "  --gds_file, -g  The name of the GDS input file"
    echo ""
    echo "Optional arguments:"
    echo "  --agds_file, -a The name of the AGDS output file to be created (default: <gds_file>.agds)"
    echo ""
    exit 0
    ;;
    *)    # unknown option
    echo "Unknown option: $1"
    echo "Use --help to display usage information"
    exit 1
    ;;
esac
done

# Check that the required argument is present
if [ -z "$GDS_FILE" ]; then
    echo "Missing required argument: --gds_file"
    echo "Use --help to display usage information"
    exit 1
fi
fname=$(basename "$GDS_FILE")

# If AGDS_FILE is not provided, set it to <gds_file>.agds
if [ -z "$AGDS_FILE" ]; then
    AGDS_FILE="$fname.agds"
fi

# Check that the input file exists and can be read
if [ ! -f "$GDS_FILE" ]; then
    echo "Input file does not exist or cannot be read: $GDS_FILE"
    exit 1
fi

# I like to live dangerously 😎
# # Check that the output file does not already exist
# if [ -f "$AGDS_FILE" ]; then
#     echo "Output file already exists: $AGDS_FILE"
#     echo "Please specify a different file name or delete the existing file"
#     exit 1
# fi

# check if FAVOR env is loaded
if [ "$CONDA_DEFAULT_ENV" != "FAVOR" ]; then
    echo "Error: The 'FAVOR' conda environment is not currently activated."
    echo "activate via 'conda activate FAVOR' or contact craut@umich.edu for help setting it up"
    exit 1
fi

# Run your code with the provided file names
echo "Running with input file: $GDS_FILE"
echo " "

# build variant csv first
echo "building var list at: ${fname}.csv"
Rscript --slave $script_dir/build_var_list.R $GDS_FILE

# run the annotation service
echo "building variant annotations at: ${fname}_annotations.csv"
python3.11 $script_dir/annotate_cpra.py -s="," -d < ${fname}.csv > ${fname}_annotations.csv

# build the agds
echo "Output file will be created as: $AGDS_FILE"
cp $GDS_FILE $AGDS_FILE
Rscript --slave $script_dir/build_agds.R $AGDS_FILE ${fname}_annotations.csv

# done!
echo "DONE!"