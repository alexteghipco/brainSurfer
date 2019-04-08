# brainSurfer
brainSurfer is (I'd like to think) a powerful surface space visualization toolbox for MATLAB. 

*NOTE* This software is provided as is. I built it to display some brains for me, and while I've tried to make it as user-friendly as possible, it's still in the process of being updated, and may not work on your machine/setup. While the code has been updated to (in theory) suppport Windows OS, it has only been debugged on macOS Mojave (most versions) in MATLAB (most versions from 2016 - 2018).  

Report all bugs to Alex Teghipco @ alex.teghipco@uci.edu!

# The boring stuff: What's new in this version?
- A new toolbar for settings

The toolbar now contains all of the options for editing your underlay, the cluster editor, and the ability to mask overlays. New functions added to the toolbar include the ability to convert between TAL and MNI for nifti images (volume space), an option to show the entire colorbar rather than threshold it by colors that exist in your current overlay, the ability to generate a quick histogram of the data in the current selection, and the ability to save and load settings from previous maps (including the data for that map if you so choose).

-  Totally revamped GUI, including new button layout to make access to common functions for manipulating statistical maps easier  

Buttons have been moved around the overlay selection listbox. New functions include the ability to delete all overlays in the selection listbox and to copy the settings for one overlay and apply them to as many other overlays as you want. I've also added a multioverlay settings GUI that allows for much greater control of visualization when multiple overlays are selected. 

- Lots of under the hood updates

Lots of bugs for changing colormaps, lighting, taking screenshots, modulating transparency have been fixed. brainSurfer.m is now faster, (better) commented, and better organized (including variable structures). There is still work to do here, so stay tuned. You can also now resize all GUIs. 

- Colormap editor

There is now a dedicated GUI for creating your own colormaps that provides realtime feedback. Colormap storage/loading is much more efficient now. 

- Make 2D overlays

3d overlays were here, now make 2d overlays in case you don't like transparency as your 2nd dimension (see plotOverlay2D)

# The boring stuff: warnings and bugs
These are some current issues that will be fixed in the future

- modulate transparency has some bugs 

Should work fine unless you have a map with both positive and negative values, in which case the transparency modulated 2D colormap that is generated is inaccurate. The real data plotted over that colormap should be translated across the x-axis.

- some options in the menu are not ready yet

There will be a GUI for creating 2D/3D colormaps but it's not ready yet (use the scripts on their own). Cluster correction is not supported yet. Statistical analysis is not yet supported. volume viewer is not yet supported. 

# TL;DR
- brainSurfer is a MATLAB toolbox for visualizing, thresholding, and manipulating surface space data. 

-It has lots of functionalities, which you can read about in the features section. My personal favorites include its ability to turn clusters into contours, to create 3D or 2D colormaps and plot 3D or 2D overlays, as well as the ability to modulate the transparency of a subset of data within an overlay, or to use a completely different overlay to modulate the transparency of an overlay. It also some nifty features for manipulating and getting cluster-level data.

- It can also project volume space data in 2mm MNI volume space onto an fsaverage surface using a registration fusion approach (see dependencies section for more info)

*Note*: brainSurfer also uses a few different methods for trying to preserve boundaries in thresholded volume space maps that are transformed into surface space. You may or may not agree with these approaches, so check the documentation before relying on them.

- Just hover over buttons/input boxes to get some help with what they do. 

# Getting started
1) Plop all of these files in any directory you want. 
2) Open matlab and navigate to the brainSurfer folder.
2) Type 'brainSurfer' into matlab to display the main GUI. Most functionality is contained within the plotUnderlay.m and plotOverlay.m functions in the ./scripts directory so you can use them to write your own scripts without relying on the GUI. 

# FAQ
1) *My volume data is not in 2mm space but I want to convert to surface space*

If you need to convert between various spaces in volume space (i.e., importing requires data to be in MNI_152_2mm space), our niftiManip repository can help with that.

2) *Help! I don't have any data!*

Check out some of the example maps that I used for testing brainSurfer in ./brainMapsforTesting

3) *I made my own colormap with brainSurfer. Where is it?*

Colormaps are saved in the ./colormaps directory. Any colormap in that directory will automatically be loaded by brainSurfer each time you launch it. You can find it in the colormap selection menu.

# How to use brainSurfer
This guide will get you on your way to using brainSurfer.

1) Select an underlay
- First, choose an underlay to load. An underlay refers to the surface structure on which we'll be plotting statistical maps. There are some preloaded FSAVERAGE brains you can choose to load. You can choose 1 or both hemispheres (I recommend using both). Load your own surface file as long as it's a freesurfer compatible surface file (sorry brainvoyagers:( check out the niftiManip repository to convert your TAL files to MNI space).

![](https://media.giphy.com/media/Ph73pwuwnapmwNOL2B/giphy.gif)

*Note* the main brainSurfer GUI just generated a new figure for patching your data. Feel free to resize it. You should also be able to resize the GUI in case it doesn't fit in your screen. 

![](https://media.giphy.com/media/dstlTkFyugaLPGGsXR/giphy.gif)

2) Edit your underlay
- You can come back to this, but now that you have an underlay loaded, you can change some of its properties. One thing we can do, is edit the sulci/gyri colors. Navigate to the menu and select edit sulci/gyri colors. The first color you select wil correspond to the gyri and the second to the sulci (you can see this referenced in the title of the color picker GUI that pops up).

![](https://media.giphy.com/media/f6ItoMoE73QPfBBibP/giphy.gif)

- You can also edit the threshold for what counts as a sulci and what counts as a gyri. This information is contained in .curv files that are loaded in with your underlay. Make sure to have these files ready to load in case you are loading a surface space underlay that isn't FSAVERAGE. 

![](https://media.giphy.com/media/KGZWLFh8u5ENB0yqhV/giphy.gif)

*Note* the color of sulci and gyri reverse to default. Also, you can now close the previous figure. brainSurfer will only patch onto the newly generated figure. This is useful in case you want to use the old one to compare to the new one. 

- Finally, we can plot the raw sulci/gyri data instead of counting values above some threshold as gyri and below as sulci.

![](https://media.giphy.com/media/L2le7srIXOWW1IuI8J/giphy.gif)

2) Load or import an overlay
- Lets try loading a file packaged with brainSurfer in ./brainMapsforTesting. If your file name does not contain reference to a hemisphere (i.e., left, right, lh, rh) then the script will ask you which hemisphere to project your overlay onto. Below, I load MNI_TFCE_LPT_FC_pFWER-05.nii_RF_ANTs_MNI152_orig_to_fsaverage_LH.nii.gz and MNI_TFCE_LPT_FC_pFWER-05.nii_RF_ANTs_MNI152_orig_to_fsaverage_RH.nii.gz

![](https://media.giphy.com/media/SxAVEfWhrUdaZO76Yq/giphy.gif)

*Note* you can select as many files as you want. 

- Try importing a file as well. The file named Visuospatial_network_binarized_IMPORT_ME_FROM_MNI_to_FSAVERAGE.nii.gz is a binarized network of the visuospatial network. Importing an overlay can occur in three different ways (this is the second prompt that comes up). Because this is an ROI we will select the second option. A second dialogue prompt will come up. This is a poweruser option so just leave the field blank and click okay (in the event ROIs overlay when projected into surface space it allows you to weight one heavier than the other). See list of features for more information on what these options do. The 'unthresholded map' option (rightmost option) is the most straightforward and conventional strategy for importing but does not work for ROIs.

![](https://media.giphy.com/media/huJBCR2zD67RKmU321/giphy.gif)

*Note* if you are not importing, your file must have "LH" or "left" in the name. This tells brainSurfer which hemisphere to patch on top of. If brainSurfer is ever confused about this, it will ask you. When you import, brainSurfer will write converted files into the same directory as the files you asked it to convert. They will be appended, and the conversion process will be performed for the right and left hemisphere. This is why both right and left hemisphere files will be loaded automatically into brainSurfer after importing. Files to import can be .nii or .nii.gz.

3) Select an overlay

- Select an overlay to patch it. Zeros in the overlay will always show up as black. Since we've selected the ROI we just imported, the colorbar is empty (i.e., there is only one value) 

![](https://media.giphy.com/media/L19BbEfCUq8XKbpO7v/giphy.gif)

*Note* You can still change the colormap to have the one value in your overlay change color. Buttons are pretty self-explanatory so check them out on your own. 

*More important note* if there is ever an error in patching (for instance, you click something too fast and the patch gets applied to the colorbar), then just close the window containing the messed up patch. And reselect the same map. 

![](https://media.giphy.com/media/U7zZN1VkKDArj3R7mH/giphy.gif)

*Followup note* if something goes wrong with your particular selections and you want to return the overlay to its initial state, use the reload overlay button. It will return all settings to default and reload the original file's data.

![](https://media.giphy.com/media/KGMlSCs3we3pgojlVz/giphy.gif)

4) Threshold overlay
- Now you can start to threshold your overlay. Because we can't really do this with the binarized ROI file we just imported, we will return to the two maps we initially loaded. Threshold positive and negative values seperately.

![](https://media.giphy.com/media/lqSf7JlvohgTLwGhxE/giphy.gif)

*Note* if you click add p-values you will be able to upload a map that contains a p-value for each vertex in currently loaded overlay. You can them change the p-value threshold on top of the value threshold that you choose. You can also threshold the cluster size using the cluster size threshold bar. 

5) Edit colormap
- Now we can edit our colormap. We can choose colormaps which come baked in with brainSurfer. 

![](https://media.giphy.com/media/Td3X7NoDkILI9jAwee/giphy.gif)

- You can quickly invert the colorbar. For instance, we might want green to correspond to negative values to make them pop (since there are so few vertices surving our negative value threshold). 

![](https://media.giphy.com/media/KffkiZABmC9LejrTNB/giphy.gif)

- You can change the number of colors in the colorbar. 

![](https://media.giphy.com/media/XHunsPO6PMiNIcU2X6/giphy.gif)

- You can change the value of the middle color in your colormap. For instance, in this map it looks like there is a stronger effect for positive values than negative ones. We can fix the middle color in the colormap to correspond to zero, or our thresholds.

![](https://media.giphy.com/media/Xymk3naiiChNe00AYP/giphy.gif)

- You can also change the opacity of the colorbar. Values closer to 0 are more transparent. 

![](https://media.giphy.com/media/PiQRrcp5jf5x3kZjhP/giphy.gif)

- Finally, we can create our own colormap!

![](https://media.giphy.com/media/gK5iHbXM4G07gzAm2B/giphy.gif)

*Note* colormaps you create will be immediately available in colormap options. The colormap GUI will dissapear upon patching. 

6) Adjustments

- In the adjustments menu, you can change the value of the bin that maps onto the limits of the colorbar. For instance, here the limits of the positive data are much higher than the negative (because there are fewer high magnitude negative values). In this case, we might decrease the limits for the positive values. 

![](https://media.giphy.com/media/gLuerJOqeIaWYTZT8t/giphy.gif)

- In this menu we can also change the map to outline clusters. 

![](https://media.giphy.com/media/cM95YUMMfNuRW2Gf6v/giphy.gif)

- These lines are really thin, but luckily, we can grow them. 

![](https://media.giphy.com/media/jUd2jUQxjrzhuX34Rm/giphy.gif)

*Note* you can also grow a whole map. The new values will take the average of the values in their corresponding cluster. Negative values will shrink the map. 

7) Modulate transparency

8) Edit clusters

9) Select multiple overlays

10) Delete

11) Save

12) Duplicate

# List of features
*Support for native space*
- Use either fsaverage brains that come with the toolbox, or render your own surface files. Then, overlay any data that fits the dimensions of your files (in .nii format). *see 'select a surface'*

*Overlay multiple maps at once*
- Once you have loaded multiple files into the GUI, you can overlay them on top of each other *use shift+click or cmd+click in the 'select an overlay' menu to select multiple overlays*
- Overlays can be moved up and down like layers in photoshop to determine which map ends up on the bottom *see the up/down buttons on the left of the 'select an overlay' menu*

*Batch load overlays*
- Select as many as 50 overlays to load into brainSurfer at once. No more file CLICK load CLICK folder CLICK another folder CLICK another folder CLICK ...wait for overlay to load...repeat 50 times. *see load button*
- left hemisphere and right hemisphere loading is not handled by seperate buttons, load them all in at once! *see load button*

*Import unthresholded NIFTI maps from MNI volume space*
- Moving from MNI space to fsaverage surface space is tricky. A new, more accurate method is implemented using scripts released by Ngo et al (see TL;DR for references). *see import button and select 'unthresholded map'*

*Import ROIs from NIFTI MNI volume space*
- Because we are downsampling when we move from MNI space to surface space, transforming ROIs is tricky. Whole integers become decimals that may represent overlaps between various different combinations of volume space clusters. Obviously, it would be best to create ROIs from stastical maps *in* surface space. However, that is not always possible. In that case, we can get at the problem by transforming every ROI seperately, and then comparing how well each of them maps onto a given vertex in surface space. Every whole integer in your input volume space file is treated as a seperate map, binarized (i.e., all values are changed to 1) and then transformed. The cluster with the highest value for a given vertex is then associated with that vertex. We can also get confidence maps for every vertex. If a single cluster wins at a particular vertex by a large amount, then we are much more confident that that vertex should be assigned to that particular cluster). *see import button and select 'ROIs map'*

*Import thresholded NIFTI maps from MNI volume space*
- Transforming a thresholded map of continuous values in volume space to surface space is also tricky for largely the same reason-- the border of that map will bleed further into vertices that are very weakly associated with voxels above threshold. As a result, some vertices will have values very far below whatever threshold was used to generate the map in volume space. One approach is to transform an unthresholded map and apply a threshold in surface space. If this is not possible, a solution is to treat the thresholded and unthresholded values in your volume space map as two seperate maps, transform both of them into surface space, and remove vertices from the thresholded map that have stronger mappings onto the transformed unthresholded map (much like the ROI approach above). You can also smooth the border of the unthresholded values after transformation to grow or shrink the thresholded map as it appears in surface space (the effect is usually subtle unless you overdo it)*see import button and select 'thresholded map'*

*Detachable renderings*
- A new surface space rendering can be opened and manipulated simply by selecting a new surface in the selection menu. This detaches the old rendering from brainSurfer, meaning that you won't be able to make any other changes to those old renderings. However, all settings in brainSurfer (including loaded files) are saved, and can be applied to the new surface rendering. *re-select a surface*

*A workspace for overlays*
- A dedicated overlay workspace allows for quick duplication, reloading, deleting, and saving of overlays *see buttons below list of overlays in the 'select an overlay' menu*

*Apply value-based and p-value thresholds*
- A p-value map can be loaded and associated with the current overlay. Two different thresholds can then be applied. *see threshold overlay menu*

*Apply cluster thresholds*
- You can remove clusters less than a certain size from the overlay. For instance, you can get a clusterform threshold using monte-carlo style simulations of your data *see threshold overlay menu*

*Threshold negative and positive values seperately*
- Come on freesurfer, why does a threshold of 3.5 have to remove all values between -3.5 and 3.5? *see threshold overlay menu*

*Adjustable limits*
- The min and max values of my overlay should be adjustable independent of the thresholds I set! *see the two text boxes in the limits subsection of adjustments menu*

*Adjustable colorbar spacing*
- Why should my colorbar be evenly spaced? If it has 2 primary colors, I should be able to force the middle of my colorbar to map onto zero, that way negative values are 1 color, and positive values are the 2nd color  *see limits subsection of adjustments menu and select 'color spacing' options*
- Same goes for thresholds in my overlay 

*Dynamic colorbar*
- Colorbar updates with opacity of overlay (and with thresholds).
- This is basic, why is it not already a standard feature?! 

*Flexible colormap options* 
- Gone are the days of being forced to choose between perceptually ambiguous 'jet' plus a handful of other lackluster  colormaps. Now you can use colormaps that people don't get upset about (https://jakevdp.github.io/blog/2014/10/16/how-bad-is-your-colormap/)! *see appearance subsection of adjustments menu and select from 'colormap' options*
- Creating your own colormaps is a breeze and saving/preloading them is automated so the next time you start matlab and fire up brainSurfer, everything will be preloaded. *from the appearance settings select colormap 'custom 1' for single color colormap or 'custom 2+' for an interpolated colormap between 2 or more clusters; saving is performed automatically after selection*
- Control the number of bins in your colormap! Ever thought of providing less information about your overlay? Now you can decrease the resolution of the colorbar/colormap by removing the number of data bins that constitute it. *type an integer into the text box 'data bins' in the appearance settings*

*Quick colormap inverter*
- Why go through the hassle of creating a whole new colormap from scratch?  *tick 'invert' in appearance settings*

*Native binarization of overlays*
- Confused as to why this simple operation is not standard in visualization software! Assign all vertices meeting threshold in the current overlay a whole integer value of 1. *tick binarize*

*Native masking of overlays*
- Another simple operation that should be standard in visualization software! Use one loaded overlay to mask another loaded overlay. *click the 'mask' button*

*Transform overlays into contour maps*
- Draws contours around clusters in your overlay. Really useful if you want to clearly delineate different maps while unimpeding a view of the anatomy underlying those maps! *tick 'outline' in appearance settings*

*Grow/shrink overlays*
- Grow or shrink your overlay by a selected size (in vertices). Any new vertices will assume the mean value of their cluster! *edit the grow/shrink text box in appearance settings; use positive values to grow by that many vertices, or negative values to shrink by that many vertices*

*Get extensive information about clusters*
- Are you tired of being unable to retrieve information about a cluster? Now you can do it with one click. This GUI will give you all the stats you could want about a cluster in your currently selected overlay. It will also let you edit the colors of clusters individually. Where else can you do that?! *click the 'edit clusters' button in appearance settings then click 'cluster size' or 'mean data' buttons; table on the far right contains spatial information about clusters that can be copied into excel; overlay can be saved as presented (either including or excluding any color changes)*

*Remove individual clusters*
- You made a functional ROI at the most liberal threshold you could stomach, but you know how there's that pesky 3-voxel cluster in the frontal lobe that keeps showing up? Use the cluster GUI to delete specific clusters from your overlays! *'delete' deletes the currently selected cluster shown in teal, 'delete all except' deletes all clusters except the currently selected one; 'change color' allows you to change the color of the selected cluster.*

*Robust smoothing options*
- You can smooth your overlay using a number of different options. You can try smoothing exclusively the borders of clusters in your overlay, although this often produces little perceptual difference. Alternatively, you can smooth all thresholded values in your overlay. In either case, smoothing can be applied either to those values only, and therefore not extent the borders of the overlay, or it can be applied to the neighborhood of every vertex, which would include vertices outside the current cluster boundaries, producing a 'bleeding' of the overlay into new vertices. *see smoothing options. Tick either values OR neighborhood; tick either border OR thresholded; choose the area that will be smoothed in terms of the number of surrounding vertices per vertex, and the steps (# of times averaging will be repeated)*

*Flexible screenshot options*
- Tired of only being able to take screenshots of predetermined rotations of your brain? Me too! Take a screenshot at the current location of the brain, or take a number of screenshots at predetermined locations that will be put into one tidy folder. No more screenshot mess. *click screenshot to take a single screenshot at current camera position; click screenshots to take several screenshots at predetermined camera positions and put them in a directory within the current working directory*

*Modulate transparency of a subset of data in the overlay*
- Tired of not being able to show "less significant" results? What's a p-value, anyway?! Use a third threshold to generate an opacity gradient between values surviving this threshold but not passing the other thresholds you've already set. Then, apply a linear opacity gradient to this range of data. Note, technically you can choose a more stringent threshold here, in which case an opacity gradient will be applied to values between this threshold and the limits of the map. 
*click the 'modulate transparency' button; the GUI will allow you to set EITHER a value-based threshold for transparency or a p-value based threshold for transparency; NOTE opacity modulated overlays cannot be saved; use the 'invert opacity-data' button to make values that are supposed to be more opaque more transparent and vice-versa*

*Use data from a different overlay to modulate transparency*
- You can also change the opacity of vertices in your currently selected overlay, based on data from a different overlay. For example, lets say we've used our ROI transformation method from MNI volume space to surface space. This also generated some confidence maps. We can i) load in our surface space ROI maps, ii) select them as our current overlay, iii) load our confidence maps in the transparency modulation menu, and iv) use the values in the confidence map to change the opacity of our the ROIs in our current overlay so that vertices we are really confident belong to a specific ROI are more opaque. *click the 'load alternate data' button to do this*

*'Clusterize' an overlay*
- convert an overlay into a file of ROIs with the 'Make ROIs' button. Each cluster is assigned an integer value between 1 and the number of clusters in the overlay. *click the 'make ROIs' button to do this*

*Control rendering properties*
- Create and save your own 'scenes' that combine camera lights, reflectivity, and all sorts of other rendering properties. *click the 'lighting' button to do this*

*Control sucli/gyri properties*
- Change sulci-gyri boundaries *make a selection from the 'edit surface properties' menu*
- Change the colors of sulci and gyri to anything you want *make a selection from the 'edit surface properties' menu*

*3D colormaps*
- Only available via scripting. Allows for the construction of a colormap that is based on a 3d colorcube of any size. Maps your overlay data directly onto this colorcube. *use the script plotOverlay3D also see plotOverlay2D*

# Dependencies and organization

brainSurfer has a number of dependencies that are packaged with it thanks to the generosity of the original authors (more on that shortly). To the extent of my knowledge, all of this software is free to modify and distribute, and the original licenses are provided along with the code. 

1) The main script in the GUI (brainSurfer.m) organizes variables that are passed on to plotOverlay.m, which handles all the hard work. The plotOverlay.m function relies on several other functions that are all packed in ./scripts/patch. The FSAVERAGED brains that are used to generate preselected underlays or to import data to surface space are found in ./brains. New colormaps that you create, and that brainSurfer will automatically load are contained in ./colormaps. Buttons loaded into the GUI can be found in ./buttons. If you would like to test some maps in brainSurfer because you don't have any of your own, navigate to ./brainMapsforTesting. 

2) brainSurfer can also import files from volume space (in NIFTI format). All of the files necessary to do this are in ./scripts/import. The transformation is achieved by files in ./scripts/import/Wu2017RegistrationFusion. This uses a registration fusion approach documentated in: Wu J, Ngo GH, Greve DN, Li J, He T, Fischl B, Eickhoff SB, Yeo BTT. Accurate nonlinear mapping between MNI volumetric and FreeSurfer surface coordinate systems, Human Brain Mapping 39:3793–3808, 2018. Code for this procedure is redistributed with brainSurfer but can be found here: https://github.com/ThomasYeoLab/CBIG. From my experience, this transformation method seems to produce much better results. If you want to implement/understand/try more conventional methods for transforming between volume and surface space, see our Atlas transformation tutorial in the NiftiMatlabTutorial repository. *NOTE* strategies for registering data are handled by original scripts in ./scripts/import. Make sure to read what they do carefully. 

3) brainSurfer uses code packaged with freesurfer to load in/save data. The same code is also used by the registration fusion scripts. These scripts are provided in /scripts/FS. License can be found within the scripts themselves. 

4) brainSurfer comes baked in with many different colormaps. All the scripts for generating these colormaps can be found in ./scripts/colors. The scripts in  ./scripts/cbrewer and ./scripts/colors/MatPlotLib as well as ./scripts/colors/cmocean.m are all provided with their respective licenses and help generate some starting color schemes. The script ./scripts/colors/cbar.m is included to display a colorbar for which transparency can be modulated differently at each bin. This script is part of the EEGLAB toolbox (https://sccn.ucsd.edu/eeglab/index.php). The script ./scripts/colorscolorcubes.m helps generate a 3d colormap and was written by MATLAB, but heavily edited. The script ./scripts/colors/customColorMapInterp.m interpolates between colors and generates colormaps. 

5) brainsurfer also comes with some scripts for converting between TAL and MNI space (as well as the possibility for converting/applying any transformation matrix). All of the scripts to do this are provided in ./scripts/convert. It comes with some powerful scripts for editing volume space files, which will be used more frequently when volumeViewer comes online. It also uses load_untouch_nii.m and save_untouch_nii.m from the NIFTI toolbox to read the headers of nifti files.

6) All other GUIs that brainSurfer draws on (and there are many) are found in ./scripts/guis. This includes:
clusterGUI.m ----> allows you to edit/save clusters in the current overlay and provides some cluster information
lightingGUI.m ----> controls lighting properties of patch
maskGUI.m ----> allows you to mask currently selected file using some other file
transparencyGUI.m ----> controls the transparency of every vertex
colormapEditorfig.m ----> edits / creates colormaps
multiOverlayGUI.m ----> allows for editing of transparency when multiple overlays are selected
uipickfiles.m ----> good GUI for file selection (comes with its own license)
