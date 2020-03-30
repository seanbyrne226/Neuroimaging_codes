#/bin/bash


########################################################################################################################################
############################################### CCSN35 - Neuroimaging Exam (L. Cecchetti) ##############################################
#
# L. SALVESEN
# Shell code (bash) - Version 0.3 (30.03.20)
#
# %%% = To be checked / modified
#
#------------------------------------------------------------- Worklog:
#
#   (28.03.20)
#   - script file creation
#   - linux OS corrupted by major crash during afni (re)installation
#   - machine back up & working - I<3Timeshift
#
#   (29.03.20)
#   - afni folder added to path - it works!
#   - added: 3dresample (1.1)
#   - when tried to resample, got warning msg about obliqueness of data (?): 
#
#            *+ WARNING:   If you are performing spatial transformations on an oblique dset, 
#             such as /home/leila/Desktop/ccsn35exam/rawdata/sub-02/sub-02_T1w.nii.gz,
#             or viewing/combining it with volumes of differing obliquity,
#             you should consider running: 
#             3dWarp -deoblique 
#             on this and  other oblique datasets in the same session.
#             See 3dWarp -help for details.
#             ++ Oblique dataset:/home/leila/Desktop/ccsn35exam/rawdata/sub-02/sub-02_T1w.nii.gz is 7.678999 degrees from plumb.
#
#   - I have chosen not to care about obliqueness, as the important thing is that T1 & EPI images have the same alignment/orientation... hopefully (?)
#       
#             https://afni.nimh.nih.gov/afni/community/board/read.php?1,142949,142949#msg-142949
#             https://afni.nimh.nih.gov/afni/community/board/read.php?1,161145,161146#msg-161146
#             https://en.wikibooks.org/wiki/Neuroimaging_Data_Processing/AFNI#Oblique_data_in_AFNI
#
#   - 3dresample implemented, LPI orientation (neurological) + Linear Interpolation method 
#            
#             3dresample -rmode {'NN', 'Li', 'Cu', 'Bk'} -> 'NN' by default
#             3dinfo
#
#   - Loosing precious time trying to automatise BIDS files format via BIDS-vxx.sh script - but it works!! :)
#
#   (30.03.20)
#   - v02: after BIDS-vxx.sh script 
#   - v025: before BIDS-vxx.sh script (dismissed)
#   - v03 & on: v02 based
#   - added: 3dSkullStrip, 3dUnifize, 3dQwarp
#   - When 3dSkullStrip implemented, got msg from afni:
#
#           The intensity in the output dataset is a modified version of the intensity in the input volume.
#           To obtain a masked version of the input with identical values inside the brain, you can either use 
#                3dSkullStrip's -orig_vol option
#           or generate a new masked version of the input by running the following command:
#                3dcalc -a $sub_anat_derivatives_bash_path*_3dresample+orig.BRIK -b $sub_anat_derivatives_bash_path*_ssbrain+orig -expr 'a*step(b)' -prefix $sub_anat_derivatives_bash_path*_ssbrain_orig_vol
#
#   - 3dSkullStrip default a bit agressive, chunks of brain clipped => tried -push_to_edge version
#   - When 3dSkullStrip -push_to_edge implemented, got warning msg from afni:
#
#           Warning 3dSkullStrip:****************
#           Surface self intersecting! trying again:
#           smoothing of 84, avoid_vent -1
#           Warning 3dSkullStrip:****************
#           Surface self intersecting! trying again:
#           smoothing of 96, avoid_vent -1
#           Warning 3dSkullStrip:****************
#           Surface self intersecting! trying again:
#           smoothing of 108, avoid_vent -1
#           Warning 3dSkullStrip:****************
#           Surface self intersecting! trying again:
#           smoothing of 120, avoid_vent -1
#           Warning 3dSkullStrip: Stubborn intersection remaining at smoothing of 120. Ignoring it.3dSkullStrip: Pushing to Edge ...
#
#   - After visual comparison showing no big diff & incomprehension of warning msg, original 3dSkullStrip kept
#   - Checking afni documentation, crossed paths with 3dUnifize as a step to be used when registrating T1w images to 3D standards 
#           
#            https://afni.nimh.nih.gov/pub/dist/doc/program_help/3dUnifize.html
#               
#                  This procedure was primarily developed to aid in 3D registration, especially
#                  when using 3dQwarp, so that the registration algorithms are trying to match
#                  images that are alike.
#
#                   3dUnifize -GM
#                       ++ Note that standardizing the contrasts with 3dUnifize will help
#                       3dQwarp match the source dataset to the base dataset.  If you
#                       later want the original source dataset to be warped, you can
#                       do so using the 3dNwarpApply program.
#                       ++ In particular, the template dataset MNI152_2009_template_SSW.nii.gz
#                       (supplied with AFNI) has been treated with '-GM'. This dataset
#                       is the one used by the @SSwarper script, so that script applies
#                       3dUnifize with this '-GM' option to help with the alignment.
# 
#
#   - 3dQwarp -allineate option triggers following computation:
#
#         ++ Starting 3dAllineate (affine register) command:
#
#         3dAllineate -base $MNItemp -source $sub_anat_derivatives_bash_path*_brain+orig.BRIK -prefix XYZ_zvsg24-_BUsCg6CZCSlZIQ.nii \
#           -1Dmatrix_save XYZ_zvsg24-_BUsCg6CZCSlZIQ -cmass -final wsinc5 -float -master BASE -twobest 7 -fineblur 4.44
#
#   
# 
#-------------------------------------------------------------  NOTES TO SELF  ---------------------------------------------------------
#
# - To assign variables, no spaces ; e.g. name=value
# - To get info about your image, use 3dinfo (afni) or fslinfo (fsl)
# - .HEAD file (afni) contains info about every previous step computed on image 
# - 3dinfo -VERB / 3dinfo -is_oblique -obliquity -ad3 -orient *filename*
# - 3dQwarp extremely CPU & time-consuming 
#
#
#
#
#
#
#=======================================================================================================================================
#
#
#
#-------------------------------------------------------------  NOTES TO USER  ---------------------------------------------------------
# 
# - Before running this script, make sure to run BIDS-vxx.sh 
#
# !!!!!! RUN THIS SCRIPT FROM WITHIN NEWLY BUILT-UP BIDS DATA DIRECTORY (e.g. ccsn35exam/data) !!!!!
#
# - If trouble with 3dSkullStrip, determine source by running:
     # afni -niml -yesplugouts &
     # suma -niml &
     # 3dSkullStrip -input Anat+orig -o_ply anat_brain -visual
#
#
# - Once everything is ready.....
#
#        - First of all, check & inspect visually the data!
#
#
#
#---------------------------------------------------------------------------------------------------------------------------------------




#------------------------------------------------------------- INITIALIZE SCRIPT -------------------------------------------------------



### Define working environment paths/variables


data_path=$(pwd)'/'
code_path=$data_path'code/'        # %%% needed??
derivatives_bash_path=$data_path'derivatives/bash/'

subjlist=$(ls --directory *sub-* | cut -d "-" -f 2)  

MNItemp='/usr/share/afni/atlases/MNI152_T1_2009c+tlrc.BRIK.gz'   # MNI152 2009 template: [1 x 1 x 1], LPI, non-linear reg, skull-stripped 


### Create loop across subjects


for s in {03..04}                              # %%% change to $subjlist when final

    do                                         # LOOP1 / %%% do not forget the done(s) at end of script

    # Define subject identifier string (BIDS format)

    sub_name='sub-'$s   

    # Define subject specific datapaths

    sub_anat_data_path=$data_path$sub_name'/anat/'      
    sub_func_data_path=$data_path$sub_name'/func/'
    sub_anat_derivatives_bash_path=$derivatives_bash_path$sub_name'/anat/'     
    sub_func_derivatives_bash_path=$derivatives_bash_path$sub_name'/func/'     



    echo -e "\n------------------------------------ Initializing subject $s \n"


#----------------------------------------------------- I - PROCESSING OF STRUCTURAL DATA -----------------------------------------------
#---------------------------------------------------------------------------------------------------------------------------------------



    echo -e "\n------------------------------------ Processing structural data for subject $s \n"

    3dUnifize -input $sub_anat_data_path*T1w.nii.gz -prefix $sub_anat_derivatives_bash_path$sub_name'_T1wU' -GM


#---------- I.1 - Resample the dataset to 1x1x1 resolution


    echo -e "\n------------------------------------ Resampling structural data for subject $s \n"

# Original T1w image has resolution 0.666667 x 0.666667 x 0.700006, is oblique and is oriented L(eft)-A(nterior)-I(nferior). [source: 3dinfo -is_oblique -obliquity -ad3 -orient *T1w.nii.gz ]
# The data will be resampled with 3dresample to 1 x 1 x 1 resolution & reoriented to anatomical convention L(eft)-P(osterior)-I(nferior) to ensure consistent orientation across dataset. 
# The resampling method will be set to Li(near) in order to smooth voxel transitions.

    3dresample -input $sub_anat_derivatives_bash_path$sub_name*_T1wU+orig.BRIK -prefix $sub_anat_derivatives_bash_path$sub_name'_T1wU_1mm' -dxyz 1.0 1.0 1.0 -rmode Li -orient lpi

# %%% Other possibility (?): 
  
#   3dAllineate -input $sub_anat_data_path*T1w.nii.gz -newgrid 1.0 -prefix $sub_anat_derivatives_bash_path$sub_name'_1mm' -final wsinc5 -1Dparam_apply '1D: 12@0'\'


#---------- I.2 - Run brain extraction

# For more info about brain extraction methods, read https://gigascience.biomedcentral.com/articles/10.1186/s13742-016-0150-5.
# %%% Doing with 3dSkullStrip - if time, will install ants (https://github.com/ANTsX/ANTs/blob/master/Scripts/antsBrainExtraction.sh) or BEaST (http://rstudio-pubs-static.s3.amazonaws.com/8431_d05daa5d49aa4cada417b6afc8ffd295.html) to do with more finesse
# %%% Maybe try @SSwarper? (https://afni.nimh.nih.gov/pub/dist/doc/program_help/@SSwarper.html)

    echo -e "\n------------------------------------ Computing brain extraction for subject $s \n"

    3dSkullStrip -input $sub_anat_derivatives_bash_path*_1mm+orig.BRIK  -prefix $sub_anat_derivatives_bash_path$sub_name'_T1wU_1mm_brain' -visual         # Output = skull-stripped brain image


# %%% If needed, 3dSkullStrip can be tuned with -shrink_fac 0.5 (0.4), -ld 30 (50; mesh density), -niter 400 (750; nb iterations), -perc_int 0.2 (closer to 1 - but why? what is an intersection?)

    echo -e "\n------------------------------------ Computing brain mask for subject $s \n"

    3dSkullStrip -input $sub_anat_derivatives_bash_path*_1mm+orig.BRIK  -prefix $sub_anat_derivatives_bash_path$sub_name'_T1wU_1mm_brain_mask' -orig_vol  # Output = binary brain mask

# %%% Probably way faster by using 3dcalc method (see worklog - 30.03.20)



#---------- I.3 - Compute & apply linear/non-linear registration to the MNI152 template

    echo -e "\n------------------------------------ Apply linear & non-linear registration to MNI152 template for subject $s \n"

    3dQwarp  -base $MNItemp -source $sub_anat_derivatives_bash_path*_brain+orig.BRIK -prefix $sub_anat_derivatives_bash_path$sub_name'_T1wU_1mm_brain2MNI' -allineate  -blur 0 3 -iwarp  

# %%% Instead of including -allineate option within 3dQwarp, maybe better to apply manually 3dAllineate beforehand to be able to personally specify parameters (see worklog - 30.03.20)


#------------------------------------------------------- II - PROCESSING OF FUNCTIONAL DATA --------------------------------------------
#---------------------------------------------------------------------------------------------------------------------------------------







#----------------------------------------------------------- FINALIZE SCRIPT -----------------------------------------------------------



done                            # Close subject loop (LOOP1)



########################################################################################################################################
########################################################################################################################################

