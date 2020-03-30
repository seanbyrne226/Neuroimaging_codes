#/bin/bash

#-------------------------------------------------------------- BIDS Folder Formatting ------------------------------------------------------------------
#---------------------------------------------------------------------- L. S. ---------------------------------------------------------------------------
#--------------------------------------------------------------------------------------------------------------------------------------------------------                               

#                                                             FINAL VERSION 3.6 - 30.03.20


# !!!!!! RUN THIS SCRIPT FROM WITHIN ORIGINAL FOLDER WHERE SUBJECT DIRECTORIES ARE (e.g. ccsn35exam) !!!!!




###------------------------------------------------ Define working environment paths


root_path=$(pwd)'/'

data_path=$root_path'data/'

code_path=$data_path'code/'

derivatives_path=$data_path'derivatives/'  

bash_path='bash/'
nipype_path='nipype/'    



###------------------------------------------------ Build up directories


mkdir $data_path

mkdir $code_path
mkdir $code_path$bash_path
mkdir $code_path$nipype_path

mkdir $derivatives_path
mkdir $derivatives_path$bash_path
mkdir $derivatives_path$nipype_path

touch $derivatives_path'README.txt'                 # Create README files - to be filled out with derivatives worklog
touch $derivatives_path$bash_path'README.txt'
touch $derivatives_path$nipype_path'README.txt'


###------------------------------------------------ Populate directories and sort data for each subject


subjlist=$(ls --directory *sub-* | cut -d "-" -f 2)  

for s in $subjlist                         

    do                                        

    sub_name='sub-'$s                                     # Define subject identifier string (BIDS format)

    echo -e "\n----------------- Initializing subject $s -----------------\n"

    mv $sub_name -t $data_path                            # Move subject folder into data folder

    mkdir $derivatives_path$bash_path$sub_name            # Create derivatives folder for subject
    mkdir $derivatives_path$nipype_path$sub_name          # Create derivatives folder for subject


    mkdir $data_path$sub_name'/anat'                      # Create BIDS anatomical data folder for subject
    mv $data_path$sub_name/*T1* -t $data_path$sub_name'/anat'   # Move subject anatomical T1w image into anat folder

    mkdir $derivatives_path$bash_path$sub_name'/anat'     # Create anatomical derivatives folder for subject (bash scripts)
    mkdir $derivatives_path$nipype_path$sub_name'/anat'   # Create anatomical derivatives folder for subject (nipype scripts)


    mkdir $data_path$sub_name'/func'                      # Create BIDS functional data folder for subject
    mv $data_path$sub_name/*run* -t $data_path$sub_name'/func'  # Move subject functional EPI data into func folder

    mkdir $derivatives_path$bash_path$sub_name'/func'     # Create functional derivatives folder for subject (bash scripts)
    mkdir $derivatives_path$nipype_path$sub_name'/func'   # Create functional derivatives folder for subject (nipype scripts)

done



###------------------------------------------------ Finalize


mv $root_path/*.json -t $data_path -u                     # Move json file with subjects metadata into data folder

cp $root_path/*.sh -t $code_path$bash_path -u             # Copy shell scripts into bash code folder