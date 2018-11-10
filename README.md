# Download
To download, visit our [releases page](https://github.com/EdwardsLabNeuroSci/NeuroMeasure/releases) above. Current versions have been compiled for Windows 7 and 10, and Mac OSX.


Additionally, .zip and tar.gz compressions are available with the full source code. Alternatively, feel free to clone the repository for your own development. 

For instructions on usage of software and explanations of functions, please view our instruction manual linked [above](https://github.com/EdwardsLabNeuroSci/NeuroMeasure/blob/master/NeuroMeasure%20v4.4%20User%20Manual.docx).

This project is open source and available for all to use.


# Purpose:
This software package was developed by The City College of New York Biomedical Engineering Department 
in collaporation with the Burke Rehabilitation Center. It was developed with the intent of providing a 
platform for researchers to quantify data acquired from human brain mapping via Transcranial Magnetic
Stimulation (TMS) assisted by Neuronavigation, such as the Nexstim(c) and Brainsight(c) platforms. 

# Features:
NeuroMeasure provides an objective, novel visual representation of 3 dimensional TMS Neuronavigation data (position of stimulus and amplitude of electromyography) overlaid on a structural MRI of the patient from whom the TMS Neuronavigation data was measured in 2 dimensional and 3 dimensional formats. From this representation, NeuroMeasure offers the following additional features:

1. Segmentation algorithms for isolating the skull for proper representation and registration of TMS Neuronavigation data
2. Clustering operations for handling of repeated-measures TMS experiments
3. Surface fitting operations for creating surface functions to characterize underlying motor cortex innervation of target muscles
4. Static measurements of datasets such as center of gravity (COG), peak recorded value, total surface area of surface fit, and volume integration of the MEP amplitude function over the surface fit.
5. Cursor position and amplitude 
6. User-selected reference point
7. Comparison tools for directly comparing multiple TMS Neuronavigation datasets, and comparison of root mean square error (RMSE), receiver operator curve (ROC), and area under curve (AUC) measurements between datasets
8. Tools for data exportation and image exportation for publication

# Data input
* Structural T1/T2 MRI scan must be in DICOM (.dcm) format. Other MRI modalities are NOT supported
* Data must be in excel spreadsheet (.xls, .xlsx) format

# Requirements to run pre-compiled binary
* 64-bit versions of Windows 7, Windows 10, Mac OSX
* 4 GB of RAM is highly recommended. Lower RAM volumes may cause processes to run more slowly or may cause processes to stop entirely
* A copy of MATLAB is NOT required to run the pre-compiled versions linked above in the [releases page](https://github.com/EdwardsLabNeuroSci/NeuroMeasure/releases) above. The below requirements are ONLY for those wishing to develop using the program's source code or compile the code themselves from source.

# Requirements to compile/run from source/develop
* MATLAB (tested on versions from 2016-2018, but may be compatible with prior or future versions)
* Curve Fitting Toolbox
* Image Processing Toolbox
* Statistics and Machine Learning Toolbox
* Text Analytics Toolbox

# Development
To run from source, compile, or develop the program, begin by running the HeadNavUI.m script within the SRC directory. This is the main script which must be run for usage of the program.

# Main Script: 
HeadNavUI.m

# Referenced Functions:
* AllOnes.m	
* ScanSelectUI.m	
* evalelip.m
* CheckTab.m		
* getimdb.m
* UITab.m			
* logErr.m
* ComparisonGUI.m		
* binmaxmapfind.m		
* maskmesh.m
* brainsegm.m		
* qtcluster.m
* centerofmass.m		
* recenter.m
* DataImportUI.m		
* checkSA.m		
* samplespacing.m
* clusterop.m		
* sliceimdb.m
* HeadNavUI.m		
* createData.m		
* surfacearea.m
* createFig.m		
* surfaceop.m
* HelpMenu.m		
* createSlice.m		
* transmatPHI.m
* HotspotQuantification.m	
* dicomcompare.m		
* transmatTHETA.m
* elipfit.m		
* truecolor.m
* ScanAlignmentUI.m	
* elipfitHEAD.m		
* zoombox.m
* elipfitMEP.m

# Referenced GUI files:
* HeadNavUI.fig	
* ScanSelectUI.fig	
* ScanAlignmentUI.fig
* HelpMenu.fig	
* DataImportUI.fig
* ComparisonGUI.fig	

# Referenced Data Files:
* Contrast_FIS_Ver1.fis	
* StandardScan.mat	
