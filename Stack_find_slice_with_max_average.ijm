/*	Macro written by Sarah E. Smith, Stowers Institute
 * 	This macro finds the slice in a stack with the maximum average value.
 */

var maxaverage = 0;
var maxslice = 1;
for (i=1; i<=nSlices; i++) {
  setSlice(i);
  getStatistics(area, mean);
  	if (mean>maxaverage){
  		maxaverage = mean;
  		maxslice = i;
  	}
}
print("Slice with maximum average intensity is ", maxslice);