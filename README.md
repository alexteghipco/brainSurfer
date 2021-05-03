# BrainSurfer-v2


<img align="left" width="250" height="166" src="https://i.imgur.com/4HJODwo.png">

BrainSurfer is a MATLAB toolbox for visualizing brain surfaces and showing statistical maps on top of them. It exists only because when left to my own devices I will invariably fall back on MATLAB to analyze brain data. I got tired of having to switch from MATLAB for data analysis to other software for visualization, so I decided to build some software to visualize brains for me directly in MATLAB. I know that there are other packages out there that will visualize brains in MATLAB as well but they tend to emphasize analysis and are sometimes not too intuitive to use for visualizing surface space data (e.g., BrainNet, SPM). The sole purpose of brainSurfer is to facilitate the process of quickly making some pretty figures of data you have already analyzed. If you work with volume space data, that will be no problem. By default, brainSurfer will give you some strategies for projecting any volume space data onto an fsaverage brain using the fancy nonlinear registration transformations recently published by folks at the Thomas Yeo Lab (see dependencies below for more information). This toolbox was built and more thoroughly tested on mac OS (mostly Big Sur), but will work in Windows also. 

### So what's changed from the older version of brainSurfer? 
Lots! It's completely rewritten from the ground up to work with the new MATLAB app framework. Because the new GUI automatically resizes in a way that preserves button layouts, you will no longer find buttons dissapearing on lower resolutions (and might notice a lot of the other buggy behaviors to now be a thing of the past). BrainSurfer is also a lot faster now, works with lots of new file types (particularly from the connectome workbench), is overall less buggy, and can display atlases for you. I'm leaving the original brainSurfer repositiory up for now because there are still a few cool features I haven't gotten around to addding to this 2.0 version yet. These include: 2-D and 3D brainmaps, a GUI for making your own colormaps, for editing clusters, for modulating the transparency of statistical maps by other maps, for saving and loading GUI states, and GUIs for changing surface properties, the location of lights, and other patch properties, especially when dispalying multiple statistical maps at once. 

*NOTE: This software is provided as is with no guarantee of any kind.*

### What file types does brainSurfer work with? 
As far as raw surfaces, you can load in freesurfer friendly formats, and gifti files. Any volume-space nifti file will be converted to fsaverage space. I will be updating brainSurfer soon to give you the option to project volume space data on to the [s900 template](https://www.humanconnectome.org/study/hcp-young-adult/document/900-subjects-data-release) (the connectome workbench template), and to move between fsaverage and s900 spaces. BrainSurfer will automatically load fsaverage and s900 templates for you and comes with multiple versions of the s900 template (midthickness, inflated, very inflated, and flat maps). 

Statistical maps can be provided in nifti format (nifti can store surface information), gifti, or cifti. Sulcal/gyral information can come from any of these formats, but also .curv files. 

Atlases can be .annot files, nifti files, or CIFTI files. You can also load in a .label as an "atlas". Note, that you will need to provide independent labels 
if your atlas is a nifti file since only cifti and .annot files contain label information. You can provide labels as a .txt file of brain structures where the indexing matches the values in your nifti file, or as an .xml file (like those used in FSL; but make sure indexing starts at 1 not 0). Providing an xml file with indexed structures will mean that you can have more structures in your atlas than are present in the nifti file (the same is true for cifti and .annot files, but not if the labels for your nifti file are provided as a .txt). BrainSurfer comes with the Harvard-Oxford atlas projected into fsaverage space, and the HCP MMP1 atlas, which was made with the s900 template, but which I've projected here onto fsaverage space as well. 

## Getting started
1) Download and place this toolbox into any directory. 
2) Open matlab and navigate to the directory you've chosen, or add it to your path.
3) Type 'brainSurfer' into the matlab command window to display the main GUI. 

You can also install this toolbox as an easier to use matlab app [here](https://www.mathworks.com/matlabcentral/fileexchange/91485-brainsurfer_1 "Mathworks File Exchange"). Be warned though, it's a little bit more buggy. 

Please email me if you run into any bugs or problems @ alex.teghipco@uci.edu!

## Quick tutorial for actually getting started





## Dependencies, organization, standalone scripts

BrainSurfer has a number of dependencies that are packaged with it thanks to the generosity of the original authors (more on that shortly). To the extent of my knowledge, all of this software is free to modify and distribute, and the original licenses are provided along with the code. 

1) The main script in the GUI (brainSurfer.m) organizes variables that are passed on to patchUnderlay.m and patchOverlay.m, which handle most of the hard work.  These function relies on several other functions that are all packed in ./scripts/patch. You can use these scripts on their own.

2) Brains that are used to generate preselected underlays are found in ./brains. These come from [freesurfer](https://surfer.nmr.mgh.harvard.edu) and the [connectome workbench](https://www.humanconnectome.org/software/connectome-workbench). New colormaps that you create, and that brainSurfer will automatically load on startup are contained in ./colormaps. Buttons loaded into the GUI can be found in ./buttons. If you would like to test some maps in brainSurfer because you don't have any of your own, navigate to ./brainMapsforTesting. 

3) When brainSurfer projects files into surface space from volume space, it uses scripts in ./scripts/import/Wu2017RegistrationFusion. This projection uses a registration fusion approach documentated in: Wu J, Ngo GH, Greve DN, Li J, He T, Fischl B, Eickhoff SB, Yeo BTT. Accurate nonlinear mapping between MNI volumetric and FreeSurfer surface coordinate systems, Human Brain Mapping 39:3793–3808, 2018. Code for this procedure is redistributed with brainSurfer but can be found [here](https://github.com/ThomasYeoLab/CBIG). From my experience, this transformation method seems to produce much better results. If you want to implement/understand/try more conventional methods for transforming between volume and surface space, see the Atlas transformation tutorial in the NiftiMatlabTutorial repository. *NOTE* strategies for registering data are handled by original scripts in ./scripts/import. Make sure to read what they do carefully. 

4) brainSurfer uses code packaged with freesurfer and the [connectome workbench](https://github.com/Washington-University/workbench) to load in/save data. The same freesurfer code is also used by the registration fusion scripts. These scripts are provided in ./scripts/FS. License can be found within the scripts themselves. NOTE: some of these scripts have been lightly edited in order to work in Windows OS without requiring a shell environment (e.g., load nifti).

4) brainSurfer comes baked in with many different colormaps. All the scripts for generating these colormaps can be found in ./scripts/colors. The scripts in  ./scripts/cbrewer and ./scripts/colors/MatPlotLib as well as ./scripts/colors/cmocean.m are all provided with their respective licenses and help generate some starting color schemes. The script ./scripts/colorscolorcubes.m helps generate a 3d colormap and was written by MATLAB, but heavily edited. The script ./scripts/colors/customColorMapInterp.m interpolates between colors and generates colormaps. 

5) brainsurfer also comes with some scripts for converting between TAL and MNI space (as well as the possibility for converting/applying any transformation matrix). All of the scripts to do this are provided in ./scripts/convert.
