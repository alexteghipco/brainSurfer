# BrainSurfer-v2


<img align="left" width="250" height="300" src="https://i.imgur.com/Q0AJWcn.png">
BrainSurfer is a MATLAB toolbox for visualizing brain surfaces and showing statistical maps on top of them. It exists only because I got tired of analyzing brain data in MATLAB, then having to switch to other software for visualization. There are other packages out there that will visualize brains in MATLAB as well, but they tend to emphasize analysis pipelines, and are not always intuitive for visualizing surface space data (e.g., BrainNet, SPM). The sole purpose of brainSurfer is to quickly make pretty figures from data that you have already analyzed. To that end, brainSurfer is GUI-based, but is built around just a couple of functions that can be easily put to work to patch surface data without the GUI. BrainSurfer supports lots of file types that you might encounter while working in freesurfer or the connectome workbench, and provides multiple strategies for projecting volume space data onto surface templates (using some fancy nonlinear registration transformations recently published by folks at the Thomas Yeo Lab; see dependencies below for more information). It also supports some fun visualization approaches: 2D and 3D statistical maps, and modulating the transparency of maps by other maps.

### So what's changed from the older version of brainSurfer? 
Lots! It's completely rewritten from the ground up to work with the new MATLAB app framework. Because the new GUI automatically resizes in a way that preserves button layouts, you will no longer find buttons dissapearing on lower resolutions (and might notice a lot of the other buggy behaviors to now be a thing of the past). BrainSurfer is also a lot faster now, works with lots of new file types (particularly from the connectome workbench), is overall less buggy, and can display atlases for you. I'm leaving the original brainSurfer repositiory up for now because there are still a few  features I haven't gotten around to addding to this 2.0 version yet. These include: 2-D and 3D brainmaps, a GUI for making your own colormaps, for editing clusters, for modulating the transparency of statistical maps by other maps, for saving and loading GUI states, and GUIs for changing surface properties, the location of lights, and other patch properties, especially when dispalying multiple statistical maps at once. 

*NOTE: This software is provided as is with no guarantee of any kind.*

### What file types does brainSurfer work with? 
As far as raw surfaces, you can load in freesurfer friendly formats, and gifti files. Any volume-space nifti file is assumed to be in MNI_152 space and will be converted to fsaverage space. I will be updating brainSurfer soon to give you the option to project volume space data on to the [s900 template](https://www.humanconnectome.org/study/hcp-young-adult/document/900-subjects-data-release) (the connectome workbench template) and to move between fsaverage and s900 spaces. BrainSurfer will automatically load fsaverage and s900 templates for you and comes with multiple versions of the s900 template (midthickness, inflated, very inflated, and flat maps). 

Statistical maps can be provided in nifti format (yes, nifti can store surface information!), gifti, or cifti. Sulcal/gyral information can come from any of these formats, but also .curv files. 

Atlases can be .annot files, nifti files, or cifti files. You can also load in a .label as an "atlas". Note, that you will need to provide independent labels 
if your atlas is a nifti file since only cifti and .annot files contain label information inside them. You can provide labels as a .txt file of brain structures where the indexing matches the values in your nifti file, or as an .xml file (like those used in FSL; but make sure indexing starts at 1 not 0). Providing an xml file with indexed structures will mean that you can have more structures in your atlas than are present in the nifti file (the same is true for cifti and .annot files, but not for nifti file where labels are provided as a .txt). BrainSurfer comes with the Harvard-Oxford atlas projected into fsaverage space, and the HCP MMP1 atlas, which was made with the s900 template, but which I've projected here onto fsaverage space as well (so it is the default atlas for both templates).

## Getting started
1) Download and place this toolbox into any directory. 
2) Open matlab and navigate to the directory you've chosen, or add it to your path.
3) Type 'brainSurfer' into the matlab command window to display the main GUI. If any of the buttons in the overlay selection panel are missing icons, just open up brainSurfer.mlapp in matlab and click the green play button in the matlab app GUI. You will only have to do this once, if at all.

You can also install this toolbox as an easier to use matlab app [here](https://www.mathworks.com/matlabcentral/fileexchange/91485-brainsurfer_1 "Mathworks File Exchange"). Be warned though, it's a little bit more buggy and lacks some functionality. For example, the app does not automatically bring up and display the figure that contains surface patches after a button in the main GUI is clicked/resolved. There is also an issue with files used to project and load in data such that temporary files may not get deleted under certain circumstances. It also has not been as thoroughly tested.

Please email me if you run into any bugs or problems @ alex.teghipco@uci.edu!

## How to use brainSurfer
This guide will get you on your way to using brainSurfer. There are 2 main steps: loading an "underlay" or surface, and loading an "overlay" or statistical map that will cover the surface. An intermediary but optional step is loading in some sulcal/gyral information, which is treated as being part of the "underlay". 

### Loading an underlay
You can select a template surface to load in automatically from the file menu. This will generate a new figure that contains the patches you've asked for. The file menu allows you to patch a surface to an existing figure, or to make a new figure. If you make a new figure, all actions you perform will only be executed on the new figure. This is handy for when you've messed something up and just want to restart without having to reload all of your overlays and reprogram your overlay settings. Adding a surface will either add or replace a surface in an existing figure.

![](https://thumbs.gfycat.com/SpanishJadedHammerheadbird-size_restricted.gif)

Note that loading up this template took some time. That's because when you load in a template, brainSurfer will automatically load in an atlas as well. The default atlas for both templates is the MMP 1.0. Patching maps usually doesn't take this long, but to make later operations on the atlas highly efficient, we are taking the time now to identify the boundaries of every ROI in the atlas. The script that does this on its own is getClusterBoundary.m.

### Inspecting underlay information
The datacursor will now display information about any vertex you click on. This will include the coordinate and the vertex you've clicked at the bare mininmum. I find this super useful since I can write down a vertex and then inspect it in a map I load into the matlab workspace, etc. Note how atlas information is being displayed both in the datacursor box and in the atlas section of the GUI. There, you will also find the atlas name.

![](https://thumbs.gfycat.com/FirstHighHornet-size_restricted.gif)

You can also look at the distribution of values in your underlay. What this really refers to is any sulci/gyri information that you have chosen to load. This histogram will be empty if you have only loaded a surface. Note the tabs on the left hand side for underlay and overlay. Each appearance settings panel is broken up into settings for the underlay, and settings for the overlay. In lots of places you will see the same settings/buttons/options so make sure you are clicked on the right tab before pressing anything! Note that for now, if you open a new surface (without sulci/gyri), this histogram will display the old sulcal/gyral file. Only by loading in a new file can you update it. 

![](https://thumbs.gfycat.com/TimelyPhysicalArabianwildcat-size_restricted.gif)

Navigate the surface patch using the rotate tool. 

![](https://thumbs.gfycat.com/ThoughtfulSoftHyena-size_restricted.gif)

You can also change the view, using either prespecified viewing angles or your own angle (access this menu either using the top view menu, or right clicking one of the brain buttons in the overlay selection section. Each button in the GUI has a tooltip that shows up if you hover over it. If you see a note about right clicking the button, it means there is a contextual menu that is triggered by a right click. On the topic of viewing angles, brainSurfer for the most part assumes your brains are not flat, and will automatically adjust the viewing angle based on the hemisphere you are editing the patch for. This is convenient unless you have a flat map loaded. If you're working with flat maps, you will notice after clicking some buttons the flat maps will sometimes "dissapear". To get them "back", just manually select the inferior view. 

![](https://thumbs.gfycat.com/ObedientRectangularKawala-size_restricted.gif)

Related to views, the goal is to eventually let you change lighting angles using a GUI (like old brainSurfer). The current lighting you see in the patch is based on some default settings I like. If you don't like them, there is still a trivial way to change them. Just find the ./scripts/defaultLights.txt file and change that to the angles at which you'd like to add lights. You can have as many as you want. Note that brainSurfer reads this in when you first start it up, so if you change this, you will need to restart brainSurfer. 

### Manually loading a surface
This is pretty simple. You can load in up to two files. BrainSurfer will assume one file is for the left hemisphere and one file is for the right hemisphere. You can technically load two left or two right hemispheres, but it will break the way overlays work (i.e., one of the brains will be assumed to be right hemisphre and you might be patching left hemisphere data onto a right hemisphere, etc).

![](https://thumbs.gfycat.com/DearestWelcomeFlies-size_restricted.gif)

It's important to make a note here about proper file names. BrainSurfer will determine whether your file is a left hemisphere or a right hemisphere brain by analyzing the filename. For surfaces, each file should have a clear reference to a hemisphere: 'left', 'lh', '.l.','_l.','_l_','right', 'rh','.r.','_r.','_r_' are all acceptable. The same generally goes for statistical brain maps/overlays, although if you are loading a CIFTI file, it is possible that it contains information on both hemispheres. To ensure brainSurfer knows this, avoid referencing a specific hemisphere in these cases (e.g., use 'LR' or something along those lines to mark these kinds of files). If you have a file with reference to both hemispheres, or no hemispheres (i.e., not a cifti), brainSurfer should ask you which hemisphere to patch that file onto. 

Note, hemispheres don't have to have the same shape and you can load in overlays with different shapes (i.e., number of vertices). 

![](https://thumbs.gfycat.com/UnevenShadowyCowbird-size_restricted.gif)

### Manually adding sulci and gyri
You can now add sulci and gyri to one or more hemispheres that you've loaded. If you've loaded in two hemispheres, you can still add sulcal/gyral information for just one hemisphere if you want. 

![](https://thumbs.gfycat.com/ScientificBraveHectorsdolphin-size_restricted.gif)

Here, I am showing addition of this kind of information to the fsaverage surface to illustrate that it will look different than if you automatically loaded in this template. That's because higher values in the curv files mean sulci (they're curves!), and typically we will assume that higher values in your sulcal/gyral file will map onto gyri. There is an easy way to fix this color scheme though. Just go into the Colormap settings tab and toggle invert colors to on. This will flip the colormap associated with the patch that contains sulcal/gyral information.

![](https://thumbs.gfycat.com/CriminalJoyousGrub-size_restricted.gif)

## This is as far as I've gotten in the tutorial today--stay tuned for the full thing!

### Changing the color of the surface

You can change the color of the surface from grey to anything else using the topmost Settings menu --> Colors --> Change default surface color
![]()

### Loading or projecting an overlay 
You can select as many files as you want here. You can even select files that do not match your current underlay. That's okay though, brainSurfer will automatically prevent you from patching those files. Even if you select multiple overlays, it will remove the ones that can't be patched and continue with your command. 

Overlay projection occurs automatically when you load in a 3D file. Note, projection currently works onto the fsaverage template. That means that if you have the s900 template loaded, you will be unable to patch any projected/imported overlay. However, the projection/import process will be successful and you'll have a new file in the same folder, appended with "_"..

### Thresholding the underlay/overlay

### Changing the limits of the underlay/overlay
The limits refer to your colormap, or colorbar, which will determine what color is assigned to each vertex of the brain. If you extend the limits, there will be bins in your colormap that don't map on any of the data in the map you are trying to patch.

### Underlay/overlay histogram gets updated with the thresholds and limits
Limits are the dark red lines and the bright red lines are the thresholds.

### Changing the values of the underlay and overlay

Positive values can be turned off from the patch. Same for negative values. You can also choose whether zeros in your map will be ignored (i.e., become transparent). It doesn't make too much sense to ignore them for sulcal/gyral information, but it does make sense for overlays, where zeros might be statistically insignificant.

### Reloading the underlay and overlay


### Binarizing the sulci and gyri 


### Changing the opacity of the whole brain and just the sulci/gyri


### Hiding hemispheres

### Thresholding overlays by cluster size

### Using a secondary p-value based threshold on overlays

### Selecting an overlay

### Rearranging overlays

### Deleting
Overlays

Hemispheres

## Atlas



## Dependencies, organization, standalone scripts

BrainSurfer has a number of dependencies that are packaged with it thanks to the generosity of the original authors (more on that shortly). To the extent of my knowledge, all of this software is free to modify and distribute, and the original licenses are provided along with the code. 

1) The main script in the GUI (brainSurfer.m) organizes variables that are passed on to patchUnderlay.m and patchOverlay.m, which handle most of the hard work.  These function relies on several other functions that are all packed in ./scripts/patch. You can use these scripts on their own.

2) Brains that are used to generate preselected underlays are found in ./brains. These come from [freesurfer](https://surfer.nmr.mgh.harvard.edu) and the [connectome workbench](https://www.humanconnectome.org/software/connectome-workbench). New colormaps that you create, and that brainSurfer will automatically load on startup are contained in ./colormaps. Buttons loaded into the GUI can be found in ./buttons. If you would like to test some maps in brainSurfer because you don't have any of your own, navigate to ./brainMapsforTesting. 

3) When brainSurfer projects files into surface space from volume space, it uses scripts in ./scripts/import/Wu2017RegistrationFusion. This projection uses a registration fusion approach documentated in: Wu J, Ngo GH, Greve DN, Li J, He T, Fischl B, Eickhoff SB, Yeo BTT. Accurate nonlinear mapping between MNI volumetric and FreeSurfer surface coordinate systems, Human Brain Mapping 39:3793–3808, 2018. Code for this procedure is redistributed with brainSurfer but can be found [here](https://github.com/ThomasYeoLab/CBIG). From my experience, this transformation method seems to produce much better results. If you want to implement/understand/try more conventional methods for transforming between volume and surface space, see the Atlas transformation tutorial in the NiftiMatlabTutorial repository. *NOTE* strategies for registering data are handled by original scripts in ./scripts/import. Make sure to read what they do carefully. 

4) brainSurfer uses code packaged with freesurfer and the [connectome workbench](https://github.com/Washington-University/workbench) to load in/save data. The same freesurfer code is also used by the registration fusion scripts. These scripts are provided in ./scripts/FS. License can be found within the scripts themselves. NOTE: some of these scripts have been lightly edited in order to work in Windows OS without requiring a shell environment (e.g., load nifti).

4) brainSurfer comes baked in with many different colormaps. All the scripts for generating these colormaps can be found in ./scripts/colors. The scripts in  ./scripts/cbrewer and ./scripts/colors/MatPlotLib as well as ./scripts/colors/cmocean.m are all provided with their respective licenses and help generate some starting color schemes. The script ./scripts/colorscolorcubes.m helps generate a 3d colormap and was written by MATLAB, but heavily edited. The script ./scripts/colors/customColorMapInterp.m interpolates between colors and generates colormaps. 

5) brainsurfer also comes with some scripts for converting between TAL and MNI space (as well as the possibility for converting/applying any transformation matrix). All of the scripts to do this are provided in ./scripts/convert.
