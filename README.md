# brainSurfer 
Report bugs to alex.teghipco@uci.edu!
*NOTE* This software is in beta. It is *ONLY* for experimental use.

# TL;DR
brainSurfer is a toolbox for visualizing and thresholding surface space data, and for projecting volume space data in MNI_152 2mm space onto fsaverage surface space. 

# Getting started
Plop all of these files in any directory you want and add them to your path in matlab (with subdirectories; eg using genpath(addpath(''))). Edit stuff at your own peril! Type 'brainSurfer' into matlab to display GUI. Use plotUnderlay and plotOverlay to write your own scripts. Hover over buttons in the GUI to understand what they do. *Note that importing data from volume space requires the installation of an additional repository and the updating of a single line in a brainSurfer script (see first FAQ)* 

# FAQ
-*Help! I can't seem to import data from volume space and I keep getting errors whenever I try!*
If you need to convert data from MNI_152_2mm space to fsaverage space, you will need to install one additional repository. brainSurfer uses a novel fusion registration method available here (https://github.com/ThomasYeoLab/CBIG) for transforming between these two spaces. In my experience, the results are superior to other available methods. To learn more about how this approach works, see Ngo et al's under review paper, "Accurate Nonlinear Mapping between MNI Volumetric and FreeSurfer Surface Coordinate Systems". 

*Note1 This CBIG repository assumes you have freesurfer installed and makes use of some bash scripting through matlab. 

*Note2 To get it to work properly on my end, I had to write some additional (but simple) scripts included in brainSurfer. In order to have these scripts work properly, you need to update convertMNI2FS with the directory in which you've placed the CBIG repository. Navigate to ./scripts and open up convertMNI2FS.m. Now look at line 4, which should start with, "CBIGDir=". Replace "'/Users/ateghipc/MATLAB-Drive/Published/projectFSAVERAGE" with the directory in which "final_warps_FS5.3" lives.   

*Note3 The approaches for importing thresholded NIFTI maps and ROI NIFTI maps are not related to this transformation method, but do rely on this transformation method.

*Note4 ONLY the importing feature of neurosynth relies on this repository.

-*Help! My data is in a different mm space but it should be convertible!*
If you need to convert between various spaces in volume space (i.e., importing requires data to be in MNI_152_2mm space), our niftiManip repository can help with that so go and check it out. 

-*Help! I don't have any data!*
Check out some of the example maps that I used for testing in ./testingMaps

-*What are the weird jpegs in the main folder?*
Sorry, needed them for buttons 

-*What's in the ./brains folder?*
LH and RH inflated FSAVERAGE files and their corresponding curvature files. This is what brainSurfer automatically loads when you choose one of these options from the surface selection menu.

# Features
*Support for native brains*
- Use either fsaverage brains that come with the toolbox, or render your own surface space .surf files. Then overlay data that fits the dimensions of your files (in .nii format). 

*Overlay multiple maps at once*
- Once you have loaded multiple files into the GUI, you can overlay them on top of each other (why can't you do this freeview/BrainNet?!)
- Overlays can be moved up and down like layers in photoshop to determine which map ends up on the bottom (why are you so clunky at this surfice/neuroelf?!)

*Import unthresholded NIFTI maps from MNI volume space*
- Moving from MNI space to fsaverage surface space is tricky. A new, more accurate method is implemented using scripts released by Ngo et al (under review). See TL;DR for more info.

*Import ROIs from NIFTI MNI volume space*
- Because we are downsampling when we move from MNI space to surface space, transforming ROIs is tricky. Whole integers become decimals that may represent overlaps between multiple different clusters. To circumvent this, we can write the cluster most associated with the subset of voxels that map onto a particular vertex, into that vertex. This leaves us with integers and confidence maps (if a cluster wins by a lot, we are more confident that vertex should be represented by that cluster). 

*Import thresholded NIFTI maps from MNI volume space*
- Transforming a thresholded map of continuous values in MNI space to surface space is also tricky for largely the same reason. The border of that map will bleed further into vertices that are very weakly associated with voxels above threshold. However, it is unclear what threshold can be used in surface space to clean this up. One solution is to project, seperately, the thresholded voxels in volume space onto surface space and to do the same for unthresholded voxels (i.e., empty zeros in the map). Vertices that are more strongly associated with the unthresholded voxels than thresholded voxels are excluded from the surface space overlay. You can also smooth the border of the unthresholded values after transformation to ensure that all transformed vertices are more strongly associated with thresholded voxels than with unthresholded voxels. 

*Detachable renderings*
- a new surface space rendering can be opened and manipulated simply by selecting a new surface. This detaches the old rendering from brainSurfer so you won't be able to make any other changes to those specific patches. However, all settings in brainSurfer (including loaded files) are saved and can be applied to the new surface rendering. 

*A workspace for overlays*
- An overlay workspace allows for quick duplication, reloading deleting and saving of overlays (why can't you do this BrainNet, Surfice, Freeview, Neuroelf, etc!)

*Apply value-based and p-value thresholds*
- a p-value map can be loaded and associated with the current overlay. Two different thresholds can then be applied. (why can't you do this or let me p-value threshold BrainNet, Surfice, Freeview, Neuroelf, etc!)

*Apply cluster thresholds*
- You can remove clusters less than a certain size from the overlay. For instance, you can get a clusterform threshold using monte-carlo style simulations of your data (see brainvoyager for nice implementation, future versions of brainSurfer will do this too)

*Threshold negative and positive values seperately*
- Come on freesurfer, why does a threshold of 3.5 have to remove all values between -3.5 and 3.5.

*Adjustable limits*
- The min and max values in my overlay should be adjustable! (good job, afni!)

*Adjustable colorbar spacing*
- Why should my colorbar be evenly spaced? If it has 2 primary colors, I should be able to force the middle of my colorbar to map onto zero, that way negative values are 1 color, and positive values are the 2nd color (why on earth is this not an option already?!)
- Same goes for thresholds in my overlay (good job freeview!)

*Colorbar updates with opacity of overlay*
- This is basic, why is it not already a standard feature?! 

*Flexible colormap options* 
- Gone are the days of being forced to choose between perceptually indistinct jet plus another 4 random default colormaps. Now you can use colormaps that people don't get upset about, and write papers about. 
- Creating your own colormaps is a breeze and saving/preloading them is automated so the next time you start matlab everything is in one place
- Control the number of bins in your colormap! Ever thought of providing less information about your overlay? Now you can decrease the resolution of the colorbar by removing the number of data bins that constitute it. 

*Native binarization of overlays*
- Also confused as to why this simple operation is not standard in visualization software!

*Native masking of overlays*
- Another simple operation that should be standard in visualization software!

*Transform overlays into contour maps*
- Draws contours around clusters in your overlay. Neat if you want to clearly delineate different maps while unimpeding a view of the anatomy underlying those maps!

*Grow/shrink overlays*
- Grow or shrink your overlay by a selected size (in vertices). Any new vertices will assume the mean value of their cluster!

*Get extensive information about clusters*
- Are you tired of being unable to retrieve information about a cluster? Now you can do it with one click. This GUI will give you all the stats you could want about a cluster in your currently selected overlay. It will also let you edit the colors of clusters individually. Where else can you do that?!

*Robust smoothing options*
- You can smooth your overlay using a number of different options. You can try smoothing exclusively the borders of clusters in your overlay, although this often produces little perceptual difference. Alternatively, you can smooth all thresholded values in your overlay. In either case, smoothing can be applied either to those values only, and therefore not extent the borders of the overlay, or it can be applied to the neighborhood of every vertex, which would include vertices outside the current cluster boundaries, producing a 'bleeding' of the overlay into new vertices.

*Flexible screenshot options*
- Tired of only being able to take screenshots of predetermined rotations of your brain? Me too! Take a screenshot at the current location of the brain, or take a number of screenshots at predetermined locations that will be put into one tidy folder. No more screenshot mess.

*Modulate transparency of a subset of data*
- Tired of not being able to show "less significant" results? What's a p-value, anyway?! Use a third threshold to generate an opacity gradient between values over this threshold and those passing the other thresholds you've already set. Then, apply a linear opacity gradient to this range of data.

*Control rendering properties*
- Create and save your own 'scenes' that combine camera lights, reflectivity, and all sorts of other rendering properties. 

*Control sucli/gyri properties*
- Change sulci-gyri boundaries
- Change the colors of sulci and gyri to anything you want

*3D colormaps*
- Only available via scripting. Allows for the construction of a colormap that is based on a colorcube of any size. Maps your overlay data directly onto this colorcube.

# Workflow
1) Surface
- First, choose an underlay to load.
- Then, edit the properties of the underlay as you see fit. 
- Now load or import an overlay. If your file name does not contain reference to a hemisphere (i.e., left, right, lh, rh) then the script will ask you which hemisphere to project your overlay onto.
2) Select an overlay to patch
- By default 'No overlay' is selected. Each time you click on an overlay you have loaded, its settings are pulled up and it is repatched (e.g., overlayed). Settings are usually saved unless you are smoothing. In that case, the 'save' button should be used. If you ever need to undo some setting and you can't seem to remember which change will restore your overlay to its pristine settings, just click 'reload'. If you want to make a copy of an overlay click 'duplicate'. If you want to delete an overlay, click 'delete'. If you want to save an overlay with its current thresholds applied, click 'save'. 
3) Threshold the patched overlay 
- Threshold your overlay using a value-based threshold (whatever unit/measurement your data represents) or load a p-value map for this overlay/data and use a p-value based threshold. If you want, you could go crazy and apply both thresholds. Last threshold is based on minimum patched (ie., overlayed) cluster size. 
4) Adjustments
- See list of features above and poke around the GUI. These are all pretty intuitive. 

# Future features
- clusterform threshold testing with TFCE or some other method depending on the kind of data you load

# Guis
1) brainSurfer.fig ----> Primary UI. Facillitates all thresholding and loading of underlays and overlays
2) clusterGUI.fig ----> Facilitates editing of individual clusters in a loaded overlay. Plots mean of data within clusters and allows for changing of colors for each cluster.
3) lightingGUI.fig ----> Facilitates rendering properties of both the underlay and overlay. Allows for adding of cameras and storage of preset 'scenes' that include sets of cameras and diffusivity/reflectance properties for the patches (i.e., overlay/underlay). 
4) maskGUI.fig ----> Facilitates the masking of one image that has been loaded, by some other image that is loaded. 
5) transparencyGUI.fig ----> Facilitates thresholding of a subset of data to which a linear gradient of opacity is applied. Controls some other opacity settings. 

# Auxillary scripts
Some auxillary functions are redistributed from some other toolboxes (chiefly freesurfer's matlab toolbox). They are redistributed in the ./scripts folder along with functions that are original. 

Here is a list of redistributed scripts and why they are needed (see the comments in the scripts themselves for individual authors)

1) cbar.m ----> brainSurfer allows you to use opacity as a dimension of data representation (much like freeview but with much more customizability). It's nice to have a colorbar that can vary in opacity to match the overlay. This is useful either if you are modulating the opacity for only a subset of the data (i.e., using a 2nd threshold) or if you change the opacity across all the data (why don't any of the other brain rendering software I've ever used already do this?!). Internal colorbar in matlab cannot vary opacity data in these ways.
2) fread3.m ----> this script is distributed with freesurfer and is used to read 3 byte integers from NIFTI files for constructing overlays
3) load_nifti.m ----> this script is distributed with freesurfer and is used to read header and volume information. Overlay data mapping onto each vertex of some surface space is often (and can be) stored as a NIFTI file.
4) read_surf.m ----> this script is distributed with freesurfer and is used to read .surf files that contain information about a surface space brain (e.g., vertices, neighbors, header info)
5) read_curv.m ----> this script is distributed with freesurfer and is used to read .curv files that contain information about the sulci and gyri of a surface space brain (e.g., a single value at each vertex of the surface space)
6) uipickfiles.m ----> this is a nice GUI for file selection
7) distinguishable_colors.m ----> another script for generating some perceptually distinct colormaps -- ideally geared towards ROI maps because each subsequent color is optimally different than the last generating clear boundaries between values on the colorbar.
8) scripts in ./scripts/MatPlotLib ----> this is a nice collection of colormaps ported from matplotlib. 
9) scripts in ./scripts/cbrewer ----> this is a nice collection of colormaps that are perceptually distinct (e.g., controlled for luminance)

Here is a list of original scripts and why they are needed

1) clusterGUI.m ----> controls the functions of clusterGUI.fig
2) colorcubes.m ----> constructs a 3D colormap 
3) getClusterBoundary.m ----> finds the vertices that form a boundary around a series of clusters. Used for outlining clusters, ROIs, or maps. Boundary is found by looking for vertices that have no neighbors with vertices for which there is data
4) getClusters.m ----> finds clusters in a set of vertices by growing vertices for which there is data, until a vertex is reached that has no neighber in the set of vertices for which there is data.
5) lightingGUI.m ----> controls the functions of lightingGUI.fig
6) maskGUI.m ----> controls the functions of maskGUI.fig
7) plot3dOverlay.m ----> plots an overlay for which the colormap is in 3D.
8) plotOverlay.m ----> workhorse of brainSurfer. Does all thresholding of data based on adjustments in brainSurfer.fig
9) plotUnderlay.m ----> plots some curv and vertex data that you've loaded in as an underlay.
10) transparencyGUI.m ----> controls the functions of transparencyGUI.fig
11) customColorMapInter.m ----> creates a custom colormap based on some selected colors
