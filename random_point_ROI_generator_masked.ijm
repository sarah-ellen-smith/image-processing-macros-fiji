/*	Macro written by Sarah E. Smith, Stowers Institute
 * 	Generate a randomly placed point ROI in a specified channel within a hyperstack	
 * 	The ROI will be within a mask in a seperate channel
 * 	Wait for user to perform action (adding to ROI manager) using the random point as a reference
 * 	(e.g., measure distance of random points to objects of interest as a control)
 * 	check to make sure desired number of ROIS are added to manager per measurement
 * 	Continue generating points until total_points is reached in ROI manager
 */

my_channel = 2; //channel of interest
mask_channel = 5; // mask channel; only generate random ROIs that land within mask
total_points = 200; // final number of measurements
desired_rois_per_measure = 2; //Number of total rois to be added to the manager per measurement. For example, one random point + one measurement point = 2 points

Stack.getDimensions(width, height, channels, slices, frames);
var slice = 1
while(roiManager("count")< (total_points/desired_rois_per_measure) ){
	// generate random integer positions in z, t, x, and y
	z = random*slices;
	z = floor(z);
	print(z);
	t = random*frames;
	t = floor(t);
	print(t);
	x = random*width;
	x = floor(x);
	print(x);
	y = random*height;
	y = floor(y);
	print(y);

	//check mask to see if point falls in mask region
	Stack.setPosition(mask_channel, z, t);
	check = getPixel(x, y);
	if(check>0){ //if the point is within the mask, proceed
		Stack.setPosition(my_channel, z, t);
		makePoint(x, y);
		waitForUser("measure random roi or skip"); // User should add a number of rois equal to desired_rois_per_measure
		if(roiManager("count")%desired_rois_per_measure==0){ //make sure the correct number of points was added
			print("count=", roiManager("count")/desired_rois_per_measure); //update user on how many measurements have been completed
		} else{
			Stack.setPosition(my_channel, z, t);
			makePoint(x, y);
			waitForUser("ROI count is off! Update ROI list"); // If correct number of points was not added, give user a chance to fix
		}
	
}

