/*	The macro was written by Sarah E Smith 
 * 	Stowers Institute for Medical Research
 * 	This macro is a batch processing macro for .ome.tiff files
 * 	that are bleach timeseries from the PE Ultraview
 * 	The files are expected to be order=xyzct channels=2 slices=51 frames=4
 * 	Channel 1 is measurement channel, channel 2 is bleach mask; bleach mask includes center of image
 * 	We are measuring sum intensity over time of puncta within bleach region
 * 	Puncta are identified and then measured as 9x9 square ROIs
 * 	Edges including top and bottom of stack are excluded
 * 	Measurements, ROIS, and processed image are saved in "Processed" folder
 * 	
 */


dir = getDirectory("Choose a Directory ");

list = getFileList(dir);
//make a new directory called "Processed" if it doesn't exist
savePath = dir+"Processed";
if(!File.exists(savePath) && !File.isDirectory(savePath)){
	File.makeDirectory(savePath);
}

for (j=0; j<list.length; j++) {
	print("3-" +  j +": " + dir + list[j]);
	if(!endsWith(list[j], File.separator) && endsWith(list[j], ".ome.tiff")){ //check for .ome.tiff files
		
	   path = dir + list[j];
	   open(path);
	   print("open" + path);

		//DO THE PROCESSING
		
		origTitle = getTitle();
		origDir = getInfo("image.directory");
		
		//start with a clean slate
		run("Clear Results");
		run("ROI Manager...");
		roiManager("reset");
		//if(roiManager("count")>0){
		//	roiManager("Delete");
		//}

		//convert to hyperstack
		run("Stack to Hyperstack...", "order=xyzct channels=2 slices=51 frames=4 display=Color");
		Stack.setChannel(1);
		Stack.setFrame(1);
		
		//z-project
		run("Z Project...", "projection=[Sum Slices] all");
		sumTitle = origTitle + "_sumProj.tif";
		path = savePath + File.separator + sumTitle;
		print("5-" +  j + ": " + path);
		saveAs("Tiff", path);

		for(t=1; t<5; t++){

		
			//Specify bleaching region
			selectImage(sumTitle);
			Stack.setFrame(t);
			Stack.setChannel(2);
			doWand(242, 248);
			run("To Bounding Box");
			run("Make Inverse");
			run("Enlarge...", "enlarge=15");
			run("Make Inverse");
			
			//find maxima and save as an roi
			Stack.setChannel(1);
			Stack.setFrame(t);
			run("Find Maxima...", "noise=15000 output=[Point Selection]");
			roiManager("Add");
			path = savePath + File.separator + origTitle + "_t"+ t + "_maxpoints.zip";
			print("6-" +  j +"-"+ t + ": " + path);
			roiManager("Save", path);
			
			
			//clear ROI manager
			roiManager("reset");
			//roiManager("Delete");
			
			//make square boxes from point selections
			getSelectionCoordinates(x, y);
			for (i=0; i<x.length; i++){
				//print(i+" "+x[i]+" "+y[i]);
				makeRectangle(x[i]-4, y[i]-4, 9, 9);
				roiManager("Add");
			}
			//save and measure
			roiManager("Deselect");
			path = savePath + File.separator + origTitle + "_t"+ t + "_boxes.zip";
			roiManager("Save", path);
			Stack.setChannel(1);
			roiManager("Measure");
			
			//measure top & bottom slices to check for unwhole spbs
			selectImage(origTitle);
			Stack.setPosition(1, 1, t);
			roiManager("Deselect");
			roiManager("Measure");
			//Stack.setSlice(51);
			for (r=0; r<roiManager("count"); r++){
				roiManager("select", r);
				Stack.setPosition(1, 51, t);
				roiManager("Update");
			}
			roiManager("Deselect");
			roiManager("Measure");
			roiManager("reset");


		} //looping through t
	//save the results
	path = savePath + File.separator + origTitle + "_results.xls";
	saveAs("Results", path);
	selectImage(sumTitle);
	run("Save");
	run("Close All");
	}//looping through images only
}//looping through files