/*	This macro is a batch processing macro.
 * 	It segments cells in yfp (ch2) and measures yfp and mT intensity properties
 * 	The macro was written by Sarah E Smith for Wahid Mulla
 * 	Stowers Institute for Medical Research
 * 	Nov 9 2016
 * 	
 * 	BEFORE RUNNING, SET MASK THRESHOLD AND BACKROUND INTENSITY MEASUREMENTS!!
 * 	
 */

//BEFORE RUNNING, SET MASK THRESHOLD AND BACKROUND INTENSITY MEASUREMENTS!!
mask_threshold = 12000;  // the lower threshold for the yfp positive cells (no background subtract)
yfp_background = 800; // background subtract for yfp channel before measuring
mt_background = 1400; // background subtract for mt channel before measuring

//setBatchMode(true); // Uncomment this to run faster.  Images will not diplay
run("Set Measurements...", "area mean standard modal min centroid stack display redirect=None decimal=3");

var dir = getDirectory("Choose data Directory");	//get directory for data
var fin = getDirectory("Choose results Directory");	//get directory for results

var list = getFileList(dir);			//get file list as array
Array.sort(list); 
for(i = 0; i < list.length; i++) {		//loop through each element in the 'list' array
	/*  The following will be done
	 *  for every file in the folder
	 */
	print(i, "of", list.length);
	if(!File.isDirectory(dir+list[i])){	//If this file is NOT a directory...
		//prepare mask and measurement images for processing
		open(dir+list[i]);		//open the image
		//run("Bio-Formats Importer", "  open=["+dir+list[i]+"] autoscale color_mode=Default view=Hyperstack stack_order=XYCZT");
		run("Z Project...", "projection=[Max Intensity]");
		rename("image");
		run("Duplicate...", "duplicate");
		rename("mask");
		selectWindow("image");
		run("Split Channels");
		selectWindow(list[i]);
		close();
		selectWindow("C1-image");
		rename("mT_"+list[i]);	
		selectWindow("C2-image");	
		rename("yfp_"+list[i]);

		//make mask of cells and add to roi list
		selectWindow("mask");
		run("Gaussian Blur...", "sigma=2");
		run("Z Project...", "projection=[Max Intensity]");
		selectWindow("mask");
		close();
		selectWindow("MAX_mask");
		rename("mask");
		setThreshold(mask_threshold, 65535);
		run("Analyze Particles...", "size=6-Infinity show=Masks display include add in_situ");
		saveAs("tiff",fin+list[i]+"_mask.tif");	//save the mask as a new image
		close();			//close the image
		
		//measure mT channel
		selectWindow("mT_"+list[i]);	
		run("Gaussian Blur...", "sigma=1");
		run("Subtract...", "value="+mt_background);//subtract background
		roiManager("Deselect");
		roiManager("Measure");
		selectWindow("mT_"+list[i]);
		close();

		//measure YFP channel
		selectWindow("yfp_"+list[i]);	
		run("Gaussian Blur...", "sigma=1");
		run("Subtract...", "value="+yfp_background);//subtract background
		roiManager("Deselect");
		roiManager("Measure");
		roiManager("Deselect");
		roiManager("Delete");
		selectWindow("yfp_"+list[i]);
		close();				

		}
	}

