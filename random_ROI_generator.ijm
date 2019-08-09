/*	Macro written by Sarah E. Smith, Stowers Institute
 * 	Generate a randomly placed point ROI in a specified channel within a hyperstack	
 * 	Wait for user to perform action using the random point as a reference
 * 	(e.g., measure distance of random points to objects of interest as a control)
 * 	Continue generating points until total_points is reached in ROI manager
 */

my_channel = 2;
total_points = 200;

Stack.getDimensions(width, height, channels, slices, frames);
var slice = 1
while(roiManager("count")<total_points){
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

	Stack.setPosition(my_channel, z, t);
	makePoint(x, y);

	waitForUser("measure random roi or skip");
	
}

