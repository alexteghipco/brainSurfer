# BrainSurfer-v2


<img align="left" width="250" height="300" src="https://i.imgur.com/Q0AJWcn.png">
BrainSurfer is a MATLAB toolbox for visualizing brain surfaces and showing statistical maps on top of them. Its purpose is twofold: to make manipulating surface data in different formats more accessible, and to quickly make pretty figures from data that you have already analyzed. BrainSurfer supports projecting data from volume space onto freesurfer's fsaverage and caret's fs_LR (s900) spaces. It's also compatible with a wide range of file types that store surface data (cifti, nifti, gifti, and freesurfer's label, annotation and morphology formats lilke .curv), and can be easily used to convert files between these formats. BrainSurfer can also perform lots of operations on surface maps (e.g., thresholding based on ranges of values, cluster sizes, and p-values, but also outlining, smoothing, combining, masking, and averaging maps among other functions) and can take automated standardized screenshots of large batches of surface maps. Its visualization capabilities include the ability to modulate the transparency of surface maps by other maps, and to represent two to three surface maps on one mesh using 2-D (square) and 3-D (cube) colormaps. It also contains a GUI for creating colormaps and supports saving GUI states so that you can share surface data visualizations exactly how you've set them up in brainSurfer with other users, even if they don't have the files you used to generate those visualizations. 

### So what's changed from the older version of brainSurfer? 
Lots! It's completely rewritten from the ground up to work with the new MATLAB app framework. Because the new GUI automatically resizes in a way that preserves button layouts, you will no longer find buttons dissapearing on lower resolutions (and might notice a lot of the other buggy behaviors to now be a thing of the past). BrainSurfer is also a lot faster now, works with lots of new file types (particularly from the connectome workbench), is overall less buggy, and can display atlases for you (which now have their own section of the GUI). BrainSurfer can now project volume space files onto fs_LR (s900) surfaces and save GUI states so that the same maps can be visualized identically on other computers, even if those computers don't have access to the files that were originally used to generate the maps. There have been lots of other small changes and added functions that would be too tedious to list, but should improve and streamline things.

### What file types does brainSurfer work with? 
Files loaded into brainSurfer are organized into the following categories: surfaces, morphological data, statistical maps (referred to as overlays), and atlases.

Surface files represent the geometry of a surface as a mesh that contains vertices and faces. These files are constrained to freesurfer friendly formats and gifti files. 

Statistical maps and morphological files are used to assign colors to each vertrex in the surface mesh. They can come in any of these formats: gifti, cifti, nifti, freesurfer's label, annotation and morphology file types (e.g., .curv, .thickness, etc). 

One feature of brainSurfer is that it automatically projects volume space data that is loaded as a statistical map (e.g., as a nifti file, though it can be any of the other file types) onto either the fsaverage or fs_LR (s900) surface, depending on which of these template surfaces has already been loaded and patched in brainSurfer. Which template to project the volume space map onto is determined based on the number of vertices in the loaded surface (32k for fs_LR and 163k for fsaverage). If a non-template surface (e.g., native surface) is patched and contains a number of vertices that matches either of the templates, loading a volume space statistical map will trigger the projection procedure. Keep this mind because in such a case it will be possible to visualize the projection on the non-template surface even though the underlying geometries do not match. Projection of volume space data onto other surfaces will be supported in a future update. 

Atlas files can be .annot files, nifti files, or cifti files. You can also load in a .label as an "atlas". Note, that you will need to provide independent labels if your atlas is a nifti file since only cifti and .annot files contain label information inside them. You can provide labels as a .txt file of brain structures where the indexing of the areas in the atlas matches the values in your nifti file, or as an .xml file (like those used in FSL; but make sure indexing starts at 1 not 0). Providing an xml file with indexed structures will mean that you can have more structures in your atlas than are present in the nifti file (the same is true for cifti and .annot files, but not for a nifti file where labels are provided as a .txt). BrainSurfer comes with the Harvard-Oxford atlas projected into fsaverage space, and the HCP MMP1 atlas, which was made with the fs_LR template but which I've projected here onto fsaverage space as well. MMP 1.0 is the default atlas for both fsaverage and fs_LR templates and will be loaded automatically whenever a surface with either 163k or 32k vertices is loaded. Again, keep in mind the possibility that a non-template surface you load contains a number of vertices that matches either of these templates, in which case the default atlas information displayed will not be accurate to the surface.

One neat trick that brainSurfer performs is that it can save any file type you load in (except surfaces) as any of the filetypes it is compatible with.

### Compatibility information
Most testing was performed on MATLAB 2021a so it is recommended that you upgrade to the newest MATLAB release. MATLAB 2020a and MATLAB 2020b will work as well though have not been as thoroughly tested. Windows 10 or mac OS (big sur) are required (although brainSurfer should work just as well with catalina).

Being able to project data from volume space and fsaverage space onto fs_LR surfaces requires downloading the [connectome workbench](https://www.humanconnectome.org/software/get-connectome-workbench).

## Installation
1) Download and place this toolbox into any directory. 
2) Add the brainSurfer directory and its subfolders to your MATLAB path as shown below.

![](https://i.imgur.com/5sScNeU.png)
<p align="center">
<img width="450" height="300" src="https://i.imgur.com/seYSZTq.png">
</p>

3) Type "brainSurfer" into the command window to summon the GUI. 
4) Provide a path to the connectome workbench bash scripts that you have previously downloaded if you would like to be able to project data from fsaverage or volume space onto the fs_LR template (and in the other directions). 

BrainSurfer will only ask you for a path to the connectome workbench the first time it is opened (see video below), but you can provide the path manually later. If no path is provided, all other brainSurfer features will still work. The path you provide is stored in ./scripts/pathToWorkBench.txt. If you did not provide any path to brainSurfer the first time you opened it, this text file will appear empty but contains a single space. If this text file is ever empty, brainSurfer will prompt you for the path again. So if you would like to update the connectome workbench path you can open this text file and delete everything in it, or just manually type the path before saving.

<p align="center">
  <img width="550" height="300" src="https://thumbs.gfycat.com/OpenFlusteredAyeaye-size_restricted.gif">
</p>


A matlab app file is in the works for easier installation in the future. For now, the version of brainSurfer that exists as an app file is missing some important functionality (2D, 3D statistical maps, transparency modulation by other maps, projecting fsaverage or volume space maps onto fs_LR). If you don't care about these features, you can find the app [here](https://www.mathworks.com/matlabcentral/fileexchange/91485-brainsurfer_1 "Mathworks File Exchange"). 

Please email me if you run into any bugs or problems @ alex.teghipco@uci.edu!

*NOTE: This software is provided as is with no guarantee of any kind.*

## Using brainSurfer
This is a more in-depth guide/tutorial on using brainSurfer. The end of this readme contains a section about dependencies and scripts in case you are into that sort of thing. The longer videos in this tutorial can be grainy, or show colors that are off. Don't worry, this shouldn't really matter if you are just trying to understand what buttons to click.

BrainSurfer is designed around the idea that when visualizing a brain surface, you would want to patch up to four sources of data at once and in the following order: 
1) The surface mesh. This is visualized underneath all other data sources.
2) Some kind of morphological data. It is assumed throughout the GUI that this is sulcal/gyral data, but it could be anything.
3) A statistical map.
4) An atlas. This is visualizied on top of all other data sources.

### Overview of the layout 
To allow for independent manipulation of these data sources, brainSurfer contains separate areas dedicated to each of them, as labeled in the image below. Showing so many different patches on top of each other can create interactions that break visualization, so the settings available for some of these sources of information are limited. For example, the widest range of visualization settings is provided for statistical maps, which are referred to as "overlays" within brainSurfer, and very few settings are provided for visualizing surface meshes. The combination of surface meshes and their morphological data is referred to in brainSurfer as an "underlay". However, having morphological data for a surface is entirely optional. If you don't provide one, a uniform grey color will be assigned to all vertices of your mesh. 

Overlays are always patched on top of surfaces, although it is possible to load overlays before patching a surface (this is not true for atlases or morphological data). Options for loading underlays and overlays are contained in the file menu, which is typically where the workflow in brainSurfer will start.

Changing the appearance of underlays and overlays is controlled in the area labeled 2 in the image below. Appearance settings are organized into categories by horizontal tabs, and most of these categories contain duplicated settings for underlays and overlays. The exception to this is the "complex overlays" category, which controls setting up patches that represent multiple overlays at once. You can use the vertical tabs in each category to switch between changing the settings for overlays or underlays. In the case of the underlay data, most of the settings will refer to manipulations of the morphological data rather than the surface itself. 

Selecting which overlays will be patched on top of the underlay is controlled in the listbox (area labeled 3 in the image below). When you load overlays, they appear here for selection. Any changes to appearance settings will be saved such that when you re-select the same overlay the saved settings will populate the GUI. Overlays are the only data source that allows for any number of simultaneous patches. That is, you can select as many overlays to patch on top of each other as you want, but you are limited to two underlays and atlases (i.e., left and right hemispheres). Although you can't edit appearance settings when multiple overlays are selected simultaneously, many of the buttons on the sides of the overlay selection listbox will still be available for you to use. These buttons give quick access to useful functions like moving overlay(s) up or down within the listbox, duplicating overlay(s), masking one overlay by another one, copying the settings of a selected overlay into other overlay(s), deleting overlay(s), taking screenshots of overlay(s) and turning the lighting on the patch on and off. Many buttons in brainSurfer contain contextual menus, including most of these listbox buttons. Every button, box, toggle, etc in brainSurfer has a tooltip that can be accessed by leaving your cursor on the button for a few seconds. This tooltip will let you know if there are options available upon right clicking the object as well.

Atlases are the only source of data that can't be loaded in the file menu. Instead, both loading options and appearance settings for atlases are available in the area labeled as 4. 

![](https://i.imgur.com/2iC4PwF.png)

### Naming conventions 
When any kind of data is loaded, brainSurfer automatically determines the hemisphere to which it belongs based on its file name and proceeds to generate a patch on the surface for that hemisphere. For surfaces, files should have a clear reference to a hemisphere: 'left', 'lh', '.l.','_l.','_l_','right', 'rh','.r.','_r.','_r_' are all acceptable. The same generally goes for overlays, although if you are loading a CIFTI file it is possible that it contains information on both hemispheres. To ensure brainSurfer knows this, avoid referencing a specific hemisphere in these cases (e.g., use 'LR' or something along those lines to mark these kinds of files). If you have a file whose name references both hemispheres, or no hemispheres (i.e., not a cifti), brainSurfer should ask you which hemisphere to patch that file onto, like shown in the image below. 

![](https://i.imgur.com/uuYIUfa.png)

### Loading an underlay template
From this section on, we'll focus on how to perform specific actions in brainSurfer so feel free to skip around to whatever you'd like more info on.

We can quickly summon a template surface with its associated morphological data using the file menu. For now, let's load the fsaverage template as shown in the video below. 

![](https://thumbs.gfycat.com/ClumsyGlumDodobird-size_restricted.gif)

You may have noticed a few things as you did this. First, the file menu contains lots of other menu options. We'll go through these in more detail later, but it's worth remembering that this is the place you'll probably need to go if you need to save or load data. 

For now, let's focus on the load surface menu option, which as you see summons a whole set of other options for you to sort through. The first choice you are presented with here is whether you want to patch your surface to a new figure, or an existing one. When you create a patch in brainSurfer, a figure detached from the main GUI pops up with the patch(es) you've requested. This figure is what will now get updated if you tinker with the appearance settings. If you have just opened up brainSurfer, you have no option but to patch to a new figure. However, you could patch to an existing figure if you've already created some patches. This will either add a hemisphere to the existing figure if that hemisphere does not exist yet, or it will replace an existing hemisphere. Creating a new figure can also be helpful in case you've messed something up, or encountered a bug, and just want to restart setting up your visualizations without having to reload all of your overlays and to reprogram your overlay settings. 

Here's what it looks like if we load in the same fsaverage template one hemisphere at a time, patching the left hemisphere to a new figure and the right hemisphere to an existing figure. 

![](https://thumbs.gfycat.com/DirectFamousAustrianpinscher-size_restricted.gif)

If you find yourself with lots of old brainSurfer patch figures lying around your desktop (because you are patching to new figures), or if you're using MATLAB to generate other figures while having brainSurfer open, you might find your screen cluttered. To remove all figures in MATLAB that aren't currently being patched to by brainSurfer go to file --> delete all figures except those actively patched by brainSurfer.

![](https://thumbs.gfycat.com/WeakLimitedDuckling-size_restricted.gif)

The next option you are presented with is whether you'd like to load one of the templates, or select your own file to patch. If you select your own surface file(s), you will need to manually attach morphological data to them using the "Load sulci/gyri" file menu option. If you went down the caret template option path, you would have noticed a lot more surface options than available for the fsaverage template. BrainSurfer does come with more or less inflated versions of the fsaverage template as well, but there are no dedicated buttons for automatically loading them in (see the files in the ./brains directory). The last choice you must make is whether you would like to patch just one hemisphere of the template you have selected, or both hemispheres. If you choose only one hemisphere and later change your mind, you can always come back and load the other hemisphere's surface to the existing figure. 

One last thing--loading up that template took some time! That's because when you load in a template, brainSurfer will automatically load in an atlas as well. The default atlas for both templates is the HCP's MMP 1.0. In addition to loading an atlas automatically, brainSurfer patches it but turns off the opacity so that you can't see it. This patching process was updating the loading bars that you saw flash across the main brainSurfer GUI. Patching usually doesn't take this long, but to make later operations on the atlas more efficient, we are taking the time now to identify the boundaries of every ROI in the atlas. If you come down to the atlas area of brainSurfer and turn the opacity up, you'll see the atlas patch appear on top of the underlay. You may have also noticed the "Loaded atlas: " area has been filled in with the atlas name. We'll explore the atlas settings a little later. 

![](https://thumbs.gfycat.com/TotalWindingIvorygull-size_restricted.gif)

### Inspecting patches
Now that you have loaded in an underlay you can interrogate different brain areas using the datacursor in the detached figure. Clicking on any vertex as shown in the video below will at the very least provide the coordinate and the vertex ID of the datatip you have placed on the figure. Since we have loaded morphological data, we also get information about the value of that data on the datatip. If we had overlay(s) selected, the same information would be displayed for each of them here as well.

I find this super useful. For example, I can now write down a vertex id and then inspect it in a map that I load into the matlab workspace independently of brainSurfer. Note, however, that the vertex ID displayed in brainSurfer is based on matlab indexing, which starts at 0. Lining up vertices between brainSurfer and other software may require subtracting 1 from the vertex ID shown in the datacursor box.

An even more useful feature of the datacursor is the ability to see what ROI within an atlas intersects with a datatip. If you have an atlas loaded with labels, the datacursor box tells you the name of the region in the atlas on which the datatip falls. If no labels are loaded, it will display the data represented in the atlas, which will be some integer that you can cross-reference against a list of ROIs (you do know what those numbers mean, right?). Note too that as you drag the datacursor, the area on the datatip gets updated in the main brainSurfer GUI, in the atlas section (see "Area on last data tip: ). 

![](https://thumbs.gfycat.com/ConfusedUnevenCockatoo-size_restricted.gif)

You can also rotate the surface patch using the rotate tool.

![](https://thumbs.gfycat.com/GoodnaturedBackAstarte-size_restricted.gif)

And you can change the view of the patch, using either prespecified viewing angles or your own angle (access this menu either using the top view menu, or right clicking one of the brain buttons in the overlay selection section. Each button in the GUI has a tooltip that shows up if you hover over it. If you see a note about right clicking the button, it means there is a contextual menu that is triggered by a right click. On the topic of viewing angles, brainSurfer for the most part assumes your brains are not flat, and will automatically adjust the viewing angle based on the hemisphere you are editing the patch for. This is convenient unless you have a flat map loaded. If you're working with flat maps, you will notice after clicking some buttons the flat maps will sometimes "disappear". To get them "back", just manually select the inferior view. 

![](https://thumbs.gfycat.com/RegularWeightyEider-size_restricted.gif)

The current lighting you see in the patch is based on some default settings I like. If you don't like them, there is still a trivial way to change them. Just find the ./scripts/defaultLights.txt file and change that to the angles at which you'd like to add lights. You can have as many as you want. Note that brainSurfer reads this in when you first start it up, so if you change this, you will need to restart brainSurfer. 

If you navigate to the limits section of the appearance settings, you can inspect the distribution of values in your underlay provided that you have loaded in some morphological data. Note the tabs on the left hand side for underlays and overlays. Each appearance settings panel is broken up into settings for the underlay and settings for the overlay. In lots of places you will see the same settings/buttons/options so make sure you are clicked on the right tab before pressing anything! To try to minimize confusion, when an underlay is loaded brainSurfer defaults to showing underlay settings across all tabs and when an overlay is loaded it defaults to showing overlay settings.

The maroon dashed lines you see in the histogram represent the limits that have been set for the data, and the bright red dashed lines represent the thresholds. When either of these settings are changed, these lines will be updated. Of course, you can zoom into the histogram and do any of the other things matlab will let you do in a figure. 

![](https://thumbs.gfycat.com/ValidAcceptableGermanshorthairedpointer-size_restricted.gif)

### Manually loading a surface
Here's how it looks when you choose to manually load a surface instead of automatically loading one, like we just did with the fsaverage template. I'll load in another template manually here, but loading in a native surface would look identical to this. 

![](https://thumbs.gfycat.com/RepentantPreciousFlee-size_restricted.gif)

You can load in up to two files. BrainSurfer will assume one file is for the left hemisphere and one file is for the right hemisphere. You can technically load two left or two right hemispheres, but it will break the way overlays work (i.e., one of the brains will be assumed to be right hemisphre and you might be patching left hemisphere data onto a right hemisphere, etc).

Note, hemispheres don't have to have the same shape and you can load in overlays with different shapes (i.e., number of vertices). 

![](https://thumbs.gfycat.com/FortunateEdibleFoxhound-size_restricted.gif)

You can change the color of the surface from the default grey to anything else using the Settings menu --> Colors --> Change default surface color. The surface color won't really matter if you end up loading in morphological data that covers the whole surface. Note that if you change this setting, any future surface you load will default to this color (which resets back to grey once brainSurfer is closed).

![](https://thumbs.gfycat.com/ReliableExhaustedKentrosaurus-size_restricted.gif)

### Manually adding morphological data to a surface
You can now add morphological data to one or more hemispheres that you've loaded. If you've loaded in two hemispheres, you can still add morphological information for just one hemisphere if you want. Just as a reminder, brainSurfer assumes morphological data has information about sulci/gyri, but you could load something else instead.

![](https://thumbs.gfycat.com/ScientificBraveHectorsdolphin-size_restricted.gif)

Here, I am showing addition of this kind of information to the fsaverage surface to illustrate that it will look different than if you automatically loaded in this template. That's because higher values in the ?h.curv files mean sulci (they're curves!), and typically we will assume that higher values in your sulcal/gyral file will map onto gyri. There is an easy way to fix this color scheme though. Just go into the colormap settings tab (make sure you are in the underlays sub-tab on the left) and toggle invert colors to on. This will flip the colormap associated with the patch that contains sulcal/gyral information.

![](https://thumbs.gfycat.com/WeakBigheartedLhasaapso-size_restricted.gif)

### Loading overlays
Loading overlays is as simple as choosing load overlays in the file menu, then selecting as many overlays as you'd like to load into brainSurfer's listbox. When you load overlays, morphological files, or atlases you'll notice brainSurfer printing some text to the MATLAB command window. You can ignore it, this is mostly for catching file loading errors in case you are running into issues. BrainSurfer uses process of elimination to determine your file type through a serious of catch statements. When loading a CIFTI file that contains information on both hemispheres, you'll notice brainSurfer will separate the hemispheres and generate two overlays for the listbox. Each of these overlay names will be appeneded "(? HEMI)" like shown in the video below (I am using the fs_LR very inflated template here)

![](https://thumbs.gfycat.com/PhysicalPastChital-size_restricted.gif)

### Projecting a volume space overlay onto a template
Okay this section is a bit long, I know. Sorry! BrainSurfer does a lot of stuff automatically when projecting surface files so I want to make sure there is documentation about what it's doing in case you need to refer to it.

To project a volume space overlay onto a surface template, simply load in a volume space file after loading in the the surface template (e.g., fsaverage or fs_LR)  on which you would like to project this file. It is assumed that the volume space file is in MNI_152 space and that it contains information on both hemispheres. As a result, one volume space file will generate two overlays--a left hemisphere and a right hemisphere overlay. BrainSurfer projects volume space data onto the fsaverage template first using a registration fusion approach documentated in: Wu J, Ngo GH, Greve DN, Li J, He T, Fischl B, Eickhoff SB, Yeo BTT. Accurate nonlinear mapping between MNI volumetric and FreeSurfer surface coordinate systems, Human Brain Mapping 39:3793–3808, 2018. Code for this procedure is redistributed with brainSurfer but can be found [here](https://github.com/ThomasYeoLab/CBIG). If the underlay you have loaded is the fs_LR template, brainSurfer will then use the connectome workbench to project the fsaverage data onto the fs_LR template. 

You'll notice each step in this projection process generates a series of output files. If you are converting volume space --> fsaverage --> fs_LR, you'll see new fsaverage and fs_LR files in whatever directory the original volume space file lived. These are appended with special strings. For example, if you load the nifti file "Visuospatial_network_binarized_IMPORT_ME_FROM_MNI.nii.gz" (contained in ./brainMapsforTesting) and select the "unthresholded" option when presented with a dialog box in brainSurfer (we'll return to this), you'll see brainSurfer generate two fsaverage files appended with "?H_RF_ANTs_MNI152_to_fsaverage.nii.gz", one for each hemisphere. These are the only files that would be produced if we had an fsaverage underlay. Since we have an fs_LR underlay you'll also notice brainSurfer created two files with the exact same name as the fsaverage projections, but in the gifti file format. These files are still in fsaverage space, but gifti files are required for the connectome workbench which is why we've created them. I find it useful to have these files around for non-brainSurfer reasons, but you can delete them if you're pressed for space since the data contained within them is redundant. The final set of files that will be produced are projected onto the fs_LR template and will be appended with the following string: "to_fs_LR.gii"

Now lets return to the conversion options you saw pop up in brainSurfer. These are different strategies I've implemented for projecting volume space files. Ideally, the file we are trying to project contains values at each voxel, in which case we can proceed with the standard projection pipeline where we effectively average all of the values within a group of voxels that maps onto a vertex. This strategy is executed by the "untresholded" conversion option that we just chose to use. 

But there is an issue with using this approach in the context of a volume space map that is thresholded, like the network we are trying to project here. Because projection requires downsampling, some vertices will invariably map onto both voxels that are below the threshold (i.e., empty in volume space) and above threshold. This may result in vertices being assigned average intensities that are below the actual threshold value that was used to constrain the data in volume space. This is why the projection we just created contained values other than 1's (the visuospatial network is binarized in the volume space map we are trying to project). 

One strategy we might use for projecting thresholded maps is to create a binary mask of the voxels that survive thresholding (anything that isn't zero) and voxels that don't survive thresholding (zero). We can project both of these masks onto the surface in order to understand which vertices map more strongly onto voxels that survive the threshold. Masking the projected data by the vertices that do map more strongly onto voxels that survive the threshold ensures that the surface projection more faithfully represents the threshold that was applied to the volume space data. This strategy is executed if the "thresholded map" option is chosen and will prompt you for some additional options. You can leave these options blank for default values, which is the best move in my opinion. Changing these values will control how much your masks are "smoothed" in surface space in order to extend the mask boundary. This is not super intuitive and will be fixed to a single option that selects by how many adjacent vertices to extend or shrink the mask boundaries. If you use this projection strategy, you will notice additional files being created, including projections of each of your masks onto the fsaverage template (appended with the string "VALS_MASK_RF_ANTs_MNI152_to_fsaverage_?H.nii.gz"). The final projections will have a slightly different file name than that generated by the "unthresholded" option (appended with the string "SURFACE_MASKED_0_SMOOTHING_STEPS_WITH_0_REPS_RF_ANTs_MNI152_to_fsaverage_?H.nii.gz"). 

The projection that results from the "thresholded" conversion option makes the most sense for converting a binarized network. But let's explore one final conversion strategy, this one suited for converting a map that contatins adjacent ROIs in volume space. In this case, using the "thresholded" conversion option does not make much sense because it will result in ambiguous boundaries between ROIs in surface space (i.e., there will be areas of continuous values rather than integers). In this case we want to use a similar masking strategy, but this time in order to understand which of the multiple ROIs maps more strongly onto each vertex. This strategy is implemented in the "ROI" conversion option which acts to create a separate binarized map for each ROI in volume space, projects each of those maps onto the surface, then performs a vertex assignment operation based on which ROI generates the highest value on each vertex. When you select this option you are given the possibility of assigning weights to each ROI. Weights are either 0s or 1s, with 1s getting preference in the winner-take-all assignment operation. The index of the weight within the vector you supply should match the integer of the ROI in the volume space map (i.e., the second number in the vector should match the ROI assigned a value of 2 in the volume space map). In most cases, you should just leave this box blank for default values (i.e., no ROI gets preference). Again, the output files for this strategy will be named slightly differently. Now you will see fsaverage files appended as "CombinedClusters_FSSpace_LH.nii.gz" and additional confidence files appended as "CombinedClusters_Confidence_FSSpace_LH.nii.gz". The confidence files retain information about what the projected values were for the winning ROI at each vertex. This allows you to inspect what percentage of voxels that got assigned a particular ROI at a given vertex actually belonged to that ROI.  

The video below shows what all three of these projection strategies look like for the visuosptial network provided in ./brainMapsforTesting
![](https://thumbs.gfycat.com/CautiousLeadingBullmastiff-size_restricted.gif)

One important thing to note is that brainSurfer does not automatically convert overlays between fsaverage or fs_LR templates. That is, if you try to load an fsaverage file onto the fs_LR template, or an fs_LR file onto an fsaverage template, brainSurfer will not automatically convert that data and will generate an error. Instead, you must use the appropriate convert menu options to convert your file, then go to load overlay in the file menu to load the new projections.

![](https://thumbs.gfycat.com/EverlastingFrequentBlacknorwegianelkhound-size_restricted.gif)

### Thresholding the underlay/overlay
One of the most basic appearance settings that you can alter is selecting a range of values within an overlay/underlay to exclude from patching. This option can be found in the data category of the appearance settings. Setting up a threshold can be done either using the lower and upper limit boxes, or by dragging the red circle on the number line to some other location on the line, which creates the segment of values that will be excluded. Note that if one or both of the draggable circles are ever outside the number line, you can always bring them back by manually changing the lower and upper limits. This number line is generated based on the upper and lower limits that have been set in the limits category of the appearance settings. By default, these are set to the min and max values of the selected overlay/underlay. If you want to follow along with the videos for the next few sections, I am using the MNI_CO_TTest_posneg_PCorrected0.001.nii_RF_ANTs_MNI152_orig_to_fsaverage_LH.nii.gz map in the ./brainMapsforTesting directory. 

![](https://thumbs.gfycat.com/QueasyFeminineJavalina-size_restricted.gif)

If you come back to the limits category of the appearance settings after changing the threshold, you will see the red vertical lines updated to reflect the new thresholds you've set.

### Changing values in the underlay/overlay
The data category of the appearance settings allows you to change the values in your overlay or underlay. "Raw" values in the drop down menu refer to the original values in the map that you loaded. Other selections here will allow you to scale or normalize these values before you apply thresholds to them. There are options provided for performing these operations over all of the data in your overlay indiscriminantly, or separately for positive and negative values in your overlay. 

![](https://thumbs.gfycat.com/ExaltedUntimelyIncatern-size_restricted.gif)

It's worth mentioning that there is a special right-click option available on the overlay version of the value panel. Right click on the drop down menu to reassign the value that was on the last datatip in the currently selected overlay. This will find all instances in the overlay of the value that was identified by the datatip, and rewrite them to be any number you choose. This can be handy for changing ROI colors and creating ROI maps.

There are lots of other quick settings you can play with in this same panel. The toggle switches here can remove positive and negative values from the overlay/underlay you've patched. The "zeros" switch controls whether zero values in the patch are visualized. This is set to "off" by default for overlays because it is assumed you'll want to threshold these kinds of maps, which involves assigning zeros to some vertices that you'll want to hide from visualization in the overlay patch. For underlays, the zero switch is set to "on" by default because it is assumed morphological data that is loaded is continuous and covers the whole surface. 

If you ever want to return to the original data as it was when you loaded it, you can press the reload button in the lower right portion of this panel. For overlays, reloading can also be performed using the top right button in the overlay selection section of the GUI. 

![](https://thumbs.gfycat.com/CarelessWigglyAmberpenshell-size_restricted.gif)

### Binarizing morphological data
To create binary sulci and gyri from your morphological data, navigate to the "binarize values" section of the data category in appearance settings (underlay tab). If you switch the toggle to on, everything above the threshold set in the threshold box will be considered gyri (white), and everything below will be considered sulci (black). These colors will be represented by the two colored rectangles. These rectangles act as buttons so you can actually redefine these colors by clicking the appropriate rectangle and selecting a new color to assign.

If you right click either of these boxes you can use some default sulci and gyri colors that I like in particular. 

You can also swap the colors you have set for sulci and gyri.

![](https://thumbs.gfycat.com/SphericalBlondDuiker-size_restricted.gif)

### Changing underlay transparency
The transparency panel of the data category in appearance settings (underlay tab) allows you to turn down the opacity of the entire underlay (surface and morphological data) without affecting the opacity of the overlay. 

It also lets you hide an entire hemisphere, including any overlays patched on it. Toggling this button will bring the hemisphere back. The two brain buttons in the overlay selection area perform the same function. 

![](https://thumbs.gfycat.com/AgreeableGloomyFennecfox-size_restricted.gif)

### Cluster thresholds for overlays
For overlays, it's possible to set a cluster threshold that will remove any set of contiguous vertices above some size threshold. You can set such a threshold either using the slider or the box contained in the cluster threshold panel (overlay tab; again data category of the appearance settings). You may have noticed that patching your map took a little extra time. That's because we needed to identify clusters in your map. Whenever this cluster process is triggered, information about clusters will be populated in the cluster tab of the appearance settings. For these next videos, I'm still using the MNI_CO_TTest_posneg_PCorrected0.001.nii_RF_ANTs_MNI152_orig_to_fsaverage_LH.nii.gz map.

![](https://thumbs.gfycat.com/GaseousFirsthandAmphiuma-size_restricted.gif)

If you want to get information about clusters without actually removing any clusters, just set the cluster threshold to 1 vertex. You can see in the cluster tab a bar chart that contains the size of each cluster in your map. Below the bar chart, there is a table displaying some information about the peak vertex in each cluster (based on the values of the overlay you have selected): the vertex ID, the coordinates of the vertex, the cluster size, the peak value inside the cluster, and the mean value across all vertices of the cluster. If you'd like to visualize the mean or max value for each cluster instead of cluster size, you can use the drop down menu in the upper right corner of this tab. Below this drop down menu, there is a "save table" button that can be used to write the table you see below the bar chart to a text file.

![](https://thumbs.gfycat.com/NegligibleRemoteGonolek-size_restricted.gif)

You can also see that this tab contains a list of buttons that can perform actions over the last datatip you have placed on the patch. These options allow you to delete the cluster on the datatip, or to keep only that cluster. You may also change the value assigned to that cluster in the overlay (note, this will apply to all vertices in the cluster), or simply change the color of the cluster as it is being currently visualized (this is the only change that will not be persistent). The options that delete clusters can be used even if multiple overlays have been selected.

![](https://thumbs.gfycat.com/EasygoingHandmadeGangesdolphin-size_restricted.gif)

Pro tip: if you need to create a new overlay by combining some clusters from an overlay with lots of clusters, you can duplicate your overlay as many times as you need, use the "delete all clusters except" button to get a separate overlay for each cluster you'd like to combine, then combine these clusters/overlays into a single overlay using the operations --> sum menu option.

### Thresholds for overlays based on p-values
You can set up to two thresholds for overlays. One represents a range of values to ignore when patching. The other represents a p-value threshold based on a map of p-values that you load in. This map can come from any file type that an overlay can come from. To load a map like this navigate to the data category and look for the p-values panel (overlay tab). 

This panel also gives you the option of FWER by correcting your p-values using FDR (q < 0.05) or bonferroni. 

![](https://thumbs.gfycat.com/TenderFrightenedAndeancat-size_restricted.gif)

### Changing the limits of the underlay/overlay
We've spent some time with the limits tab of the appearance settings, but we haven't yet talked about the limits, which are set to the min and max values of your overlay by default. These limits control what values lie at the two ends of the colorbar you see to the right of your patch. 

![](https://thumbs.gfycat.com/LastDistortedIndianglassfish-size_restricted.gif)

By the way, you can toggle the visibility of this overlay colorbar by going to settings --> colors --> colorbar --> visibility menu. There are a few other tricks in this colorbar menu, including the ability to flip the colorbar so it lies horizontally below the patch (settings --> colors --> colorbar --> orientation),  rather than vertically and to the right of it.

![](https://thumbs.gfycat.com/HeartfeltFeistyBasilisk-size_restricted.gif)

### Colormaps and their appearance
The overlay colorbar that you see is set up based on the settings chosen in the colormap tab. This tab also happens to include a few more complex operations that can be performed on the overlay map. 

The top drop-down menu allows you to choose from a number of different colormaps. Most of these maps come packaged with brainSurfer (see dependencies section), but you can also create your own colormaps and add them to the ./colormaps directory to have brainSurfer load them in on startup. These colormaps will appear at the end of the drop-down menu. The second drop-down menu allows you to change what values will be assigned to the midpoint of the colorbar. If you have positive and negative values in your overlay and you are working with a colormap with lots of color diversity, it makes sense to force the midpoint or center of your colorbar to map onto 0. If you have thresholds set, you may even want the midpoint to map onto whatever thresholds you've selected. If this is not the case though, you might want to ignore the midpoint or center, and spread values evenly across the colorbar, based on the limits you've set. This is the default option.

![](https://thumbs.gfycat.com/FrequentGenerousGraywolf-size_restricted.gif)

You can also control how many bins there are in the colormap/colorbar. This determines how many values there will be along the colorbar you see. This panel also gives you the option to quickly invert the colors on your colorbar, and to change the opacity of the overlay.

![](https://thumbs.gfycat.com/RipeGrandAustraliankestrel-size_restricted.gif)

To facilitate the creation of new colormaps, brainSurfer can be used to summon a secondary GUI for colormap creation by going to settings --> colors --> create colormap. First, select a colormap to use as a starting point from the top drop-down menu. This will contain the same colormaps available in the main GUI. Once you do this, you should see a colorbar pop up. You can now change either the leftmost, rightmost, or middle colors on this colorbar. The colors in between these three points will be interpolated automatically. To do this, select which of these three points you'd like to change using the radio toggle, then drag the three r/g/b sliders around until you come up with the color you'd like to use as a replacement for this point. Note that the sliders update the color of the square image on the right, allowing you to preview the color you'll assign to the colorbar. Once you have settled on a color you like, click the "update on bar" button to assign it. If you would like for the interpolation of colors to ignore the middle color, flip the "include middle in interpolation" toggle. You can now use the two buttons on the bottom of this GUI to save your colormap. If you press "save colormap", the colormap will be written to the ./colormap folder and immediately loaded into brainSurfer where you can now select it as the colormap for an overlay or an underlay. If you press "save colormap and apply to currently selected overlay" the new colormap will be saved and immediately applied to the overlay currently selected in brainSurfer. 

![](https://thumbs.gfycat.com/WatchfulShabbyIndianpalmsquirrel-size_restricted.gif)

Before returning to the other settings in the colormap tab for overlays (in appearance settings), lets switch to the underlay version of this tab. Although the colorbar for the underlay is not displayed anywhere, you can still alter its settings here. The additional options you saw as part of the overlay version of this panel are missing here because they involve performing operations that don't really make sense for morphological data, like converting a thresholded map into ROIs. Note that the opacity setting here takes a while to execute--this only affects the underlay setting.

![](https://thumbs.gfycat.com/ActualClassicJaguarundi-size_restricted.gif)

Now lets return to the overlay version of this panel and take a closer look at the settings we skipped over. The outline drop down menu gives you the option to either create a contour/outline around the whole overlay that you see in the patch ("map" option), or to create a contour around each ROI in your map ("ROI" option). The latter option will work correctly if your map contains only integers corresponding to ROIs. Otherwise, if you select the "map" option for this drop-down menu, brainSurfer will identify each cluster in your overlay and outline/contour each one individually. The outline for each cluster is assigned a single value: the mean value across all vertices of the cluster.

![](https://thumbs.gfycat.com/CostlyNiftyArcticseal-size_restricted.gif)

The grow/shrink setting (you can either use the slider or the box to set it) allows you to either grow or shrink an overlay by a certain amount of neighboring vertices. If a positive value is provided the overlay will be grown, but if a negative value is provided it will be shrunk. New vertices that the overlay is expanded into are assigned a value based on their neighborhood (average). Note that the overlay colormap settings also have settings for opacity and changing bins. 

![](https://thumbs.gfycat.com/FirmSereneCygnet-size_restricted.gif)

The grow/shrink setting works a little bit differently if the overlay has been outlined. Positive values grow the outline outward into vertices not belonging to the original overlay (i.e., before outlining). Since an outline or boundary like this can't be shrunk, negative values will act to grow the outline inwards into vertices that did belong to the original overlay (again, prior to outlining). 

![](https://thumbs.gfycat.com/DeadlyCooperativeHypacrosaurus-size_restricted.gif)

The final setting in this colormap tab gives you the option to binarize your overlay. You can either binarize your whole overlay, assigning it one value: 1. Or, you can binarize each cluster in the overlay separately, assigning it an integer value based on its index in the list of clusters in your overlay. This option amounts to converting a map of continuous values into a map of ROIs and can be used to create your own atlases.  

![](https://thumbs.gfycat.com/SmoothVapidAmazontreeboa-size_restricted.gif)

### Smoothing 
You can smooth both underlays and overlays using the smooth tab. This is the only tab that does not contain individual tabs for overlays and underlays just because there are so few settings to tinker with here.

Smoothing operates identically for overlays and underlays. For each vertex, the values of the nearest n vertices will be averaged m times, with n being set by the area box and m being set by the steps box. A toggle button also allows you to either constrain the neighborhood definition to only those vertices that survive your thresholds, or to all vertices in the overlay. When all vertices are considered to be part of the neighborhood, any vertices that lie outside the thresholds are assigned values based on the neighborhood average. Smoothing does not occur until the smooth button is pressed. This is a state button that can be "unpressed" to return the overlay to its original state, or at least before smoothing was applied. 

![](https://thumbs.gfycat.com/LankyLateIndianhare-size_restricted.gif)

Note that smoothing overlays that are outlined will not work. 

### Selecting multiple overlays
Displaying multiple overlays at once is as simple as as command or shift-clicking (ctrl on windows) multiple overlays in the listbox. Although it wasn't mentioned before, it's also worth noting that selecting "No overlay" will display only the underlay data without patching any overlays.

![](https://thumbs.gfycat.com/RegularUnconsciousChital-size_restricted.gif)

Overlays will generally appear in the order in which they are patched, unless overlays have different transparencies, in which case the overlay that is more transparent will always show up on top. One bug that is matlab patch-function related that you should be aware of is that if you have multiple patches on top of each other that are at least partly transparent, instead of mixing the colors, areas of the overlay that overlap will only show  whichever patch is on top. To display two overlapping overlays, one of the overlays should have an opacity of 1. If you are trying to display three or more overlays, all of which show overlap, I would recommend outlining some of these overlays to improve the interpretability of the visualizations.

![](https://thumbs.gfycat.com/BareBeneficialGemsbok-size_restricted.gif)

Notice that multiple colorbars are plotted when multiple overlays are patched. If the colorbars are intruding onto the patch, simply resize the patch figure. Counterintuitively, making it smaller can sometimes help more than enlargening it. 

![](https://thumbs.gfycat.com/UglyRegularKoi-size_restricted.gif)

Also note that when multiple colorbars are plotted, each colorbar is shown with a superimposed title based on the overlay to which it belongs. If you would like to turn off these titles (e.g., to take screenshots), go to settings --> colors --> colorbar --> titles. It's also possible to change the spacing in between multiple colorbars to bring them closer together or further apart by going to settings --> colors --> colorbar -->  change spacing.

![](https://thumbs.gfycat.com/AggressiveImpossibleAuk-size_restricted.gif)

If you navigate to the limits tab of the appearance settings, you'll find that there are now multiple intensity histograms plotted, one for each overlay you have patched.

![](https://thumbs.gfycat.com/DiscreteSardonicKingfisher-size_restricted.gif)

When selecting multiple overlays, you will not be able to adjust most overlay appearance settings, however there are a bunch of other functions and settings that you could still use, including the buttons that flank the overlay selection area. 

![](https://thumbs.gfycat.com/GrimyUnconsciousElkhound-size_restricted.gif)

### Overlay selection buttons
These buttons provide quick access to highly used functions. For example, the top buttons on the left hand side move overlays that have been selected either up or down within the listbox. The reload button on the top right reloads a single slected overlay to its state when you first loaded it. 

![](https://thumbs.gfycat.com/DisguisedAncientGyrfalcon-size_restricted.gif)

The three buttons on the middle-left side control general visualization properties. For instance, the two brain buttons toggle the visibility of their corresponding hemispheres in the patch, and the flashlight button toggles the patch lighting. All three of these buttons will work even when multiple overlays are selected. Right clicking the brain buttons will allow you to change the viewing angle.  

![](https://thumbs.gfycat.com/AbandonedEarnestIrishredandwhitesetter-size_restricted.gif)

On the middle right side are three buttons are useful for manipulating overlays. The top button of the three copies the settings within one overlay that has been selected into any numer of other overlays, the middle button duplicates a single overlay that has been selected, and the mask button uses the currently selected overlay to mask any number of other overlays. Pressing the top or bottom of the three buttons will summon a second listbox that contains all of the overlays in brainSurfer, so that you can select all of the overlays that you'd like to copy data into/mask. In the listbox for copying settings, you'll see several check boxes that can be used to control which settings don't get copied over. 

![](https://thumbs.gfycat.com/DependentHarmfulBarnowl-size_restricted.gif)

I missed the mask button in the video above, so here's one that illustrates how this button works.

![](https://thumbs.gfycat.com/CautiousSlipperyDotterel-size_restricted.gif)

The button on the bottom right deletes all of the overlays that have been selected. If you right click this button, you can summon a second listbox to choose which overlays to delete, or you can delete all of the overlays that you've loaded. 

![](https://thumbs.gfycat.com/VelvetyCircularGreathornedowl-size_restricted.gif)

The camera button on the bottom left takes screenshots. If you left click the button you'll take a single screenshot of the figure with your patches, exactly as you see it now. After the screenshot is taken, another matlab script will be used used to generate a cropped image of just the brain portion of the patch (e.g., tight crop on the brain and excluding the colorbar). This file will be appended with the "_CROPPED". Right clicking the camera button brings up more useful ways to take screenshots. For example, you can have brainSurfer go to each of the viewing locations in the view settings and take a screenshot of each view (you'll get to choose the file name but each screenshot will be appended "_lateral", etc; cropped images will still be generated). You can also have brainSurfer perform these kinds of standardized screenshots of each view for every single overlay that you have loaded, or just a select number of overlays (selection occurs by secondary listbox).

![](https://thumbs.gfycat.com/LoneRedDikkops-size_restricted.gif)

You can also change the font size of the overlay selection listbox, trim the length of the overlay names that are displayed in the listbox, and even rename overlays by right clicking the overlay selection listbox.

![](https://thumbs.gfycat.com/PoisedFrenchCat-size_restricted.gif)

### Operations
The operations menu adds some more options for manipulating overlays, but mostly adds ways of creating new ones. Pressing any of these buttons will summon a secondary listbox to select all overlays over which you want the operation you've selected performed. The top two operation options can be used to take the absolute value of overlays, and to multiply overlays by -1 in order to flip positive and negative values. The remaining options will create a new overlay and add it to the listbox. The new overlay will be based on adding, averaging, or taking the standard deviation of the overlays you have selected in the secondary listbox.  

![](https://thumbs.gfycat.com/MarriedFrailLcont-size_restricted.gif)

### Atlases
The atlas section of brainSurfer is used to both load in atlases, and to control their appearance. See previous sections for more information about loading atlases (e.g., what kind of file types are compatible, etc). When an atlas is loaded, its patch is persistent, like an underlay patch. By default, when an atlas is loaded its opacity is set to 0 so that it doesn't distract from the other data you are trying to patch. As you can see in the video below, most of the appearance settings are identical to appearance settings that we've already covered when looking at overlays and underlays. The main difference here is that outlines of the atlas are patched in a different way than outlines of underlays and overlays in order to make sure that the atlas will always appear on top of all of the other patches, even if its transparency is turned down. Another difference is that it doesn't make too much sense to grow an atlas, so you can only grow the outline of an atlas. To save time on compute, the way atlas outlines are grown is handled a bit differently. The price for the near instant patch changes is that atlas outlines cannot be shrunk like overlay/underlay outlines. The only new setting here is the ability to toggle the atlas colorbar, which is also hidden by default. 

![](https://thumbs.gfycat.com/SilverTallBeauceron-size_restricted.gif)

There are also some hidden contextual menus here. If you click on the section that shows the area on the last datatip, it will bring up the option to extract this area into a new overlay that you can select from the listbox. 

![](https://thumbs.gfycat.com/CrispFakeJaeger-size_restricted.gif)

You can right click either of the two drop down menus to randomize the colors in your atlas colorbar, to try to import the default colors from your atlas if they were available in your cifti or annotation file, and to save your current colorbar. When trying to make the colors of adjacent ROIs "pop" I would recommend using the perceptually distinct colormap, which was designed such that each added color is as different from the others as possible. Although this helps visualize ROIs and atlases, it's still possible that two neighboring areas are assigned similar colors. In these cases it is helpful to shuffle the colors in the colormap. The option to save the atlas colormap is there in case you liked a particular shuffle and would like to be able to re-load it some other time. Note that currently it is not possible to use default colors from an atlas file and outline the ROIs in an atlas at the same time. 

![](https://thumbs.gfycat.com/HonoredUnsungDuiker-size_restricted.gif)

### Saving data
One useful feature of brainSurfer is that it allows you to save an overlay that you've loaded into any file type that it is compatible with. This means you can load a gifti or a nifti file and save it as cifti, or even as freesurfer's morphology, annotation and label files. You should note though that freesurfer's label files are binary, and their annotation files are based on colors assigned to each vertex. If you are saving continuous values in an overlay to an annotation file, the map you load will look like it was generated with fewer bins in the colormap. It's also important to mention that saving an overlay to a file means that any thresholds, changes to values (e.g., scaled, normalized), smoothing, and cluster or value editing that has been performed to the overlay will be saved. To save an overlay just navigate to the file menu --> save overlays. This will summon a secondary overlay selection listbox that can be used to select all of the files that you would like to save.  

In the video below I save the atlas ROI we extracted in the last step. BrainSurfer asks me for a hemisphere to patch the file I saved to because the automatically generated file name had no clear reference to a hemisphere. 

![](https://thumbs.gfycat.com/GregariousGenerousChameleon-size_restricted.gif)

One issue you might run into is that brainSurfer always splits CIFTI files into left and right hemisphere overlays (if both are available). So what do you do if you load a CIFTI file, alter the two overlays it makes up in brainSurfer, and then want to save the changes? Unfortunately, you'll have to separately save each of those two overlays as CIFTI files. However, after saving them, you can merge them into one single file using the option in file --> combine saved CIFTI files.

You can also save and load GUI states. This is pretty self-explanatory but it just saves brainSurfer exactly as it is now with all of the overlays you have loaded and the settings that you have set up, etc. You can share GUI states with users that don't have access to the same files that were used to generate your state, and those users will still be able to visualize all of the overlays exactly how you set them up. To load and save GUI states, see the file menu. We are about to hit complex overlays in this tutorial so lets take this opportunity to load in a save state I have distributed with brainSurfer that is meant to provide an example for setting up different complex overlays. 

![](https://thumbs.gfycat.com/FrayedCoarseHoneybadger-size_restricted.gif)

### Complex overlays
The neatest thing you can do in brainSurfer is to set up a complex overlay. This is a single patch that represents data from multiple overlays in some way. You can find the area to do this in the complex overlays tab of the appearance settings. In that tab, you'll find three sub-tabs for setting up different kinds of complex overlays. For any selected overlay, you can set up either a 2D or 3D overlay, but not both. You can modulate the transparency of any overlay, which includes a 2D or 3D overlay. You can select multiple overlays to patch that have 1D, 2D or 3D overlays set up, allowing you to superimpose outlined overlays or areas in other overlays on top of a 2D or 3D overlay. Note that when you have patched a complex overlay, you won't be able to change most of the other appearance settings. Any settings you can't change will dissapear from the GUI. 

Try loading in the only save state that is provided with brainSurfer to follow along with the videos in this section, and to tinker around with setting up complex overlays.

#### Transparency modulated overlays
The simplest of the three complex overlays to set up is the transparency modulated overlay. This is where you modulate the transparency values at each vertex of the currently selected overlay by some other overlay that you have already loaded. You can use the drop down menu to select the overlay that will be used to perform the modulation. After you make this selection you will notice the overlay get updated in the patch and a 2-D colormap appear in the transparency modulation sub-tab. The 2-D colormap is a representation of how brainSurfer assigns transparency values to each vertex of the selected/patched overlay. For any vertex in the selected/patched overlay, a transparency value between 0 and 1 is assigned based on where the value of the same vertex in the modulation overlay falls on a linearly spaced line. This line is comprised of 1000 points or "bins" and each point/bin is assigned a value lying between the limits of the modulation overlay. The min and max opacity values can be manually changed to something other than 0 and 1 using the appropriate boxes in this tab. The limits of the modulation overlay can also be manually changed. By default, brainSurfer separates positive and negative values in the modulation overlay and maps transparencies for each of these separately so that only values around zero are treated as opaque. If instead you'd like brainSurfer to consider all negative values to be more opaque and all positive values to be less opaque, you can switch the "separate pos/neg" toggle to "Off". 

Note that if you modulate the transparency of a 2D or 3D map, there will be no colormap that pops up in the transparency modulation tab. For 2D maps, a future update will display a cube here with the third dimension being white. For 3D maps I can't think of a good way of providing a visual representation of modulation (it would have to be 4D? Send me ideas if you have them!). 

![](https://thumbs.gfycat.com/BonySelfassuredDeinonychus-size_restricted.gif)

#### 2D overlays
Setting up a 2D colormap works very similar. In fact, you have fewer options to tinker with here. All you have to do is select any two overlays that will be used to form the 2D patch using the two drop down menus. The first overlay will be the y-axis of the 2D colormap, and the second overlay will be the x-axis. One tricky thing here is that it's possible to set up a 2D overlay that does not contain the overlay you have selected. Keep this in mind because the next time you click back on this overlay in the overlay selection listbox, it will repatch the 2D overlay as you have set it up. The same is also true for 3D colormaps.  

![](https://thumbs.gfycat.com/GaseousPoshAmericanredsquirrel-size_restricted.gif)

Notice that in the video above we set up a 2D colormap after setting up a transparency modulation and the new 2D colormap is still modulated by the map we previously selected. When setting up either 2D or 3D colormaps, you'll have better visualizations if no thresholds are applied to the overlays, which is in line with how I think of the utility of this feature--to visualize interactions among surface maps where there isn't a super clear significance threshold that can be set (e.g., component maps from PCA or ICA, etc). Visualizations of thresholded maps suffer when there is increasingly less overlap between the maps because this is more likely to result in vertices mapping on the very far edges of the square colormap, which creates sharp contrast between colors in the patch.

![](https://thumbs.gfycat.com/AchingSpicyBobwhite-size_restricted.gif)

If you ever find colors in your map too ambiguous, there are a few things you can do. If you don't want to change the colormap, you can just drag the datacursor across areas of the surface and this will produce a corresponding datatip on the colormap. In other words, the color of the vertex you've clicked on gets a datatip in the colormap so you can see exactly where that vertex falls on the colormap. 

![](https://thumbs.gfycat.com/WhirlwindIdenticalBorer-size_restricted.gif)

You could also play with the two buttons in this tab. You might have noticed that the 2D colormap is formed by interpolating between the two colorbars of the selected overlays if they were positioned vertically (i.e., along the y-axis). This generates the least muddy 2D colormaps, but it means the colors associated with the second map become detached from the colorbar that was set up for that map. An alternative to interpolating between the two colorbars, is to place the 2nd colorbar horizontally (along the x-axis) and average the colors of the two colorbars. In most cases, I find the default option in brainSurfer to work best because it is more likely to create 4 distinct quadrants in the 2D colormap, enhancing interpretability. But in some cases placing that 2nd colorbar on the x-axis can help with visualization. Note that this is a state button and you can "unpress" it to return the colormap to normal. 

You might also try rotating the colormap. Press the rotate color to move the colormap clockwise by 90 degrees. If none of this works, I recommend changing the colorbars associated with the two maps you've selected to set up a 2D colormap. 

![](https://thumbs.gfycat.com/InsidiousDarkAsp-size_restricted.gif)

One final feature here that I won't get into too much but will just mention is that you can use a second map of ROIs to create a 2D scatterplot for the two overlays you have selected to make this patch. This will extract the values of the two overlays that fall into the ROIs in some other overlay and create a 2D scatterplot from those values. The scatterplot helps identify regions that show a stronger effect in one overlay than another. 

![](https://thumbs.gfycat.com/FrightenedFlusteredAntarcticfurseal-size_restricted.gif)

#### 3D overlays
3D overlays are setup just like 2D overlays, by selecting the three overlays that will be used to generate the complex overlay. Notice that the buttons in the 3D overlay are greyed out since we just setup a 2D overlay. To make them available, we should remove our complex overlay by setting one of the drop down menus to "No overlay". Doing so, repatches the non-complex overlay that has been selected (i.e., reverts the patch to what we saw before we setup the 2D overlay). 

After you chose your 3 overlays, you may have noticed that brainSurfer launched a figure with a bunch of cubes, and that this figure ended up being transfered into the colormap area of the 3D complex overlay tab. Each of these cubes represents a point in the 3D space we've created using the three overlays. The values of these points are based on the colorbars you've set up for each of the overlays separately. Each cube has a different color that is interpolated between the colors that are set at its edges: R,G,B,C,M,Y,K. You can't change the colors on this colorcube because the colors here have already been selected to maximize interpretability by making each edge as distinct as possible. Generally, 3D colormaps look better the more "cubes" or bins you have per dimension. The problem is that we have to patch each of these cubes as a separate object, so creating a colormap with 8+ cubes takes forever. I've noticed 8 cubes seems to be the sweet spot, and pregenerated a 3D colormap using that many cubes. This colormap gets loaded into brainSurfer whenever you select 8 cubes to save time. 

![](https://thumbs.gfycat.com/TestyMeatyFirebelliedtoad-size_restricted.gif)

You may have also noticed that there is space between each cube that allows us to see deeper into the colormap. This is by design, and you can quickly change the amount of space between each cube by changing cube size. This change occurs instantaneously so don't worry about playing around with this. 

![](https://thumbs.gfycat.com/JitteryBigheartedFly-size_restricted.gif)

If you are struggling to interpret the patch, dragging a datacursor around the brain will highlight which cube a vertex falls into (similar to the 2D colormaps). To return the colormap to "normal" just right click any of the buttons in this 3D tab and click "make cube opacity uniform". 

![](https://thumbs.gfycat.com/WelllitPracticalKoalabear-size_restricted.gif)

By right clicking, you may have noticed the option to create a 3D scatterplot using some ROIs. This is the same function available to 2D colormaps as well where you can choose an overlay of ROIs and extract all values within those ROIs in the three overlays you have selected to create your 3D patch. These three sets of values are then plotted on a 3D scatterplot allowing you to see whether ROIs map more on one of the overlays than the others. 

![](https://thumbs.gfycat.com/MealyDirtyBonobo-size_restricted.gif)

Note that you can also rotate the colors in the colormap. This works by rotating colors on a single one of the three axes by 90 or 180 degrees. For some patches, switching around the colors on the edges of the colormap can really help improve interpretability. You can also  switch the maps that fall on each of the three axes of the colormap using the drop down menu. Note that when you rotate a 3D colormap, the resulting patch will be persistent such that if you click some other overlay and return to the one that contains the 3D map, the rotated patch will be regenerated. However, the rotated 3D colormap itself is not persistent. So clicking back on that overlay will bring up a default non-rotated colormap that will not match up correctly to the patch. This will be fixed in a future update. 

![](https://thumbs.gfycat.com/PlasticOblongIvorybackedwoodswallow-size_restricted.gif)

### GUI appearance
You can change the background of the figure that contains your patches using the menu in settings --> color --> change background of brain figure. Changing the color of the background will not cause any issues for generating cropped images as part of the process of taking screenshots. 

The colors in the GUI itself can be changed as well. BrainSurfer can be set to a "dark" mode using the menu in settings --> GUI --> dark mode. Setting the GUI to "light" mode will return brainSurfer to the default PC-from-the-80s beige color scheme. There is also an option to make brainSurfer lighter using the "ligher" mode (everything becomes white). Note, changing this "mode" might take a minute or two.

![](https://thumbs.gfycat.com/CrazyMatureCub-size_restricted.gif)

![](https://thumbs.gfycat.com/DarlingBleakEyra-size_restricted.gif)

## Dependencies, organization, standalone scripts
This section will be update with more information soon, including how to use the scripts brainSurfer calls on without the GUI (i.e., to make patches in matlab, etc).

BrainSurfer has a number of dependencies that are packaged with it thanks to the generosity of the original authors (more on that shortly). To the extent of my knowledge, all of this software is free to modify and distribute, and the original licenses are provided along with the code. 

1) The main script in the GUI (brainSurfer.m) organizes variables that are passed on to patchUnderlay.m and patchOverlay.m, which handle most of the hard work.  These function relies on several other functions that are all packed in ./scripts/patch. You can use these scripts on their own. They rely on the MATLAB patch function. 

2) Brains that are used to generate preselected underlays are found in ./brains. These come from [freesurfer](https://surfer.nmr.mgh.harvard.edu) and the [connectome workbench](https://www.humanconnectome.org/software/connectome-workbench). New colormaps that you create, and that brainSurfer will automatically load on startup are contained in ./colormaps. Buttons loaded into the GUI can be found in ./buttons. If you would like to test some maps in brainSurfer because you don't have any of your own, navigate to ./brainMapsforTesting. 

3) When brainSurfer projects files into surface space from volume space, it uses scripts in ./scripts/import/Wu2017RegistrationFusion. This projection uses a registration fusion approach documentated in: Wu J, Ngo GH, Greve DN, Li J, He T, Fischl B, Eickhoff SB, Yeo BTT. Accurate nonlinear mapping between MNI volumetric and FreeSurfer surface coordinate systems, Human Brain Mapping 39:3793–3808, 2018. Code for this procedure is redistributed with brainSurfer but can be found [here](https://github.com/ThomasYeoLab/CBIG). From my experience, this transformation method seems to produce much better results. If you want to implement/understand/try more conventional methods for transforming between volume and surface space, see the Atlas transformation tutorial in the NiftiMatlabTutorial repository. *NOTE* strategies for registering data are handled by original scripts in ./scripts/import. Make sure to read what they do carefully. 

4) brainSurfer uses code packaged with freesurfer and the [connectome workbench](https://github.com/Washington-University/workbench) to load in/save data. The same freesurfer code is also used by the registration fusion scripts. These scripts are provided in ./scripts/FS. License can be found within the scripts themselves. NOTE: some of these scripts have been lightly edited in order to work in Windows OS without requiring a shell environment (e.g., load nifti).

4) brainSurfer comes baked in with many different colormaps. All the scripts for generating these colormaps can be found in ./scripts/colors. The scripts in  ./scripts/cbrewer and ./scripts/colors/MatPlotLib as well as ./scripts/colors/cmocean.m are all provided with their respective licenses and help generate some starting color schemes. The script ./scripts/colorscolorcubes.m helps generate a 3d colormap and was written by MATLAB, but heavily edited. The script ./scripts/colors/customColorMapInterp.m interpolates between colors and generates colormaps. 

