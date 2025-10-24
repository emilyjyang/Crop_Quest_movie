//@ File (label="Input directory",style="directory") inputdir
//@ File (label="Output directory",style="directory") outputdir
//@ int(label="Channel for actin, cannot be 0", style = "spinner") Channel_Actin
//@ int(label="Channel for second landmark -- select 0 if none", style = "spinner") Channel_Landmark
//@ string (label="File type", choices={".tif",".czi",".nd2",".ome.tiff",".tif"}, style="listBox") Type
//@ Integer (label="crop size", style = "bar",value=150) cropsize
//@ Boolean (label="Processed with Gaussian blur? (for raw images)") Gau
//@ Boolean (label="Maximum projection of the movie? (for single channel, actin cable Z stack movie)") Max
//@ Boolean (label="Bleach correction? ") Bleach


//Prepare your cell number ROI using transmitted light images beforehand can save you a lot of time. 

list = getFileList(inputdir);


if (Channel_Actin == 0) {
	  print("No actin cable movie can be cropped. Please start the macro again.");
}
else {

for (i=0; i<list.length; i++) {
    showProgress(i+1, list.length);
    filename = inputdir + File.separator+ list[i];
    if(Type == ".ome.tiff" ){
    Fname_temp = File.getNameWithoutExtension(filename);
    Fname = File.getNameWithoutExtension(Fname_temp);   
    }
    else{
     Fname = File.getNameWithoutExtension(filename);   	
    	}
    Folder_output_final = outputdir +File.separator+ Fname;
    File.makeDirectory(Folder_output_final);
    print("\\Clear");
	roiManager("reset");
	roiManager("Show None");
	run("Clear Results");
	run("Collect Garbage");
	
	print(filename);
    print(list[i]);
    
    if (endsWith(filename, Type)) {
        roiManager("reset");
        run("Bio-Formats Importer", "open=" + filename + " autoscale color_mode=Default split_channels view=Hyperstack stack_order=XYCZT");
        //run("Bio-Formats Macro Extensions");
        //Ext.openImagePlus(filename);
    	
    	run("Select None");
        Stack.getDimensions(width, height, ch, slices, frames);
        imagewidth = width;
        imageheight = height;
        imageZstack = slices;
        id = getImageID();
        
      
        run("Set Measurements...", "bounding redirect=None decimal=9");
		run("Measure");
		px = width / getResult("Width");
		
		if (imageZstack <2) {
        	Z_stack =0;
        }
        else {
        	Z_stack =1;
        }
		
		// Rename channels      
        CA =Channel_Actin-1;
      	CL =Channel_Landmark-1;
      	selectImage(id);
       	Actinchannel = getImageID();
       
    	if (Channel_Landmark != 0) {
    		selectWindow(list[i] + " - C="+CA);
       		Actinchannel = getImageID();
      	  	selectWindow(list[i] + " - C="+CL);
    	    Lanmarkchannel = getImageID();
     	}
		
		// Merge channels
		
		
		if (Channel_Actin != 0 && Channel_Landmark == 0) {
		ch=1;
		selectImage(Actinchannel);
		mergedImage = getImageID();
		}
		
		
		if (Channel_Actin != 0 && Channel_Landmark != 0) {
		ch=2;
		selectImage(Actinchannel);
		Actinchannel_name = getTitle();
		selectImage(Lanmarkchannel);
		Landmarkchannel_name = getTitle();
		run("Merge Channels...", "c1=["+Landmarkchannel_name+"] c2=["+Actinchannel_name+"] create");
		mergedImage = getImageID();
		
		}

		
		run("Subtract Background...", "rolling=50 stack");
		
		if (Bleach != 0){
		run("Bleach Correction", "correction=[Simple Ratio] background=0");
		}
		
		saveAs("Tiff", Folder_output_final+File.separator+Fname+"-rmBKG50.tif");
		
		
		
		id_new = getImageID();
		if(ch == 1){
		run("Green");
		run("Enhance Contrast", "saturated=0.35");
		}
		if(ch == 2){
		Stack.setDisplayMode("composite");
		Stack.setChannel(2);
		run("Green");
		run("Enhance Contrast", "saturated=0.35");
		Stack.setChannel(1);
		run("Magenta");
		run("Enhance Contrast", "saturated=0.35");		
		}
		run("Tile");
		
		setTool("points");
		roiManager("reset");
		RoiBegin = roiManager("count");
		if (RoiBegin > 0) {
			roiManager("delete");
		}
		roiManager("Show All with labels");
		run("Labels...", "color=white font=18 show draw");
		run("Select None");
		waitForUser("Click on the center of a cell. Add to ROI Manager (keyboard shortcut is t).\n"+
            "Repeat previous step.\n"+
            "When done click OK");
        roiManager("Save", Folder_output_final+File.separator+Fname+"-CellnumberRoiSet.zip");
        CellRoi = roiManager("count");
        
        run("Duplicate...", "use");
		run("Labels...", "color=white font=18 show draw");
		roiManager("Show All with labels");
		run("Flatten");
		saveAs("Tiff", Folder_output_final+File.separator+Fname+"-cells marked.tif");
		close(); close();
		
		for (j = 0; j < CellRoi; j++) {
			roiManager("reset");
			roiManager("Open", Folder_output_final+File.separator+Fname+"-CellnumberRoiSet.zip");
			selectImage(id_new);
			roiManager("select", j);
			roiManager("rename", j+1);
			nCell = j+1;
			pad_nCell = IJ.pad(nCell, 3);

			Roi.getCoordinates(x, y);
		
			run("Select None");
			selectImage(id_new);
			makeRectangle(x[0]-cropsize/2, y[0]-cropsize/2, cropsize, cropsize);
			run("Duplicate...", "duplicate");
			cropImage = getImageID();
			
			if(ch == 1){
			Stack.setChannel(1);
			resetMinAndMax();
			run("Enhance Contrast", "saturated=0.35");
			run("Enhance Contrast", "saturated=0.35");
			}
			if(ch == 2){
			Stack.setChannel(1);
			resetMinAndMax();
			run("Enhance Contrast", "saturated=0.35");
			run("Enhance Contrast", "saturated=0.35");
			
			Stack.setChannel(2);
			resetMinAndMax();
			run("Enhance Contrast", "saturated=0.35");
			run("Enhance Contrast", "saturated=0.35");			
			}
			
			saveAs("Tiff", Folder_output_final+File.separator+Fname+"-cell"+pad_nCell+".tif");
			
			if (Gau ==1) {
			selectImage(cropImage);
			run("Gaussian Blur...", "sigma=1 stack");
			if(ch == 1){
			Stack.setChannel(1);
			resetMinAndMax();
			run("Enhance Contrast", "saturated=0.35");
			run("Enhance Contrast", "saturated=0.35");
			}
			if(ch == 2){
			Stack.setChannel(1);
			resetMinAndMax();
			run("Enhance Contrast", "saturated=0.35");
			run("Enhance Contrast", "saturated=0.35");
			
			Stack.setChannel(2);
			resetMinAndMax();
			run("Enhance Contrast", "saturated=0.35");
			run("Enhance Contrast", "saturated=0.35");			
			}
			}
			if (Max ==1) {
			run("Z Project...", "projection=[Max Intensity] all");
			Max_cropImage = getImageID();
			run("Enhance Contrast", "saturated=0.35");
			saveAs("Tiff", Folder_output_final+File.separator+Fname+"-cell"+pad_nCell+"-MAX.tif");
			run("RGB Color", "frames keep");
			Max_cropImage_gif = getImageID();
			saveAs("gif", Folder_output_final+File.separator+Fname+"-cell"+ pad_nCell +"-MAXgif.gif");
			selectImage(Max_cropImage_gif);
			close();
			//selectImage(Max_cropImage);
			//close();
			selectImage(cropImage);
			close();
			}
			else{
			selectImage(cropImage);
			run("RGB Color", "frames keep");
			cropImage_gif = getImageID();
			saveAs("gif", Folder_output_final+File.separator+Fname+"-cell"+ pad_nCell +"-gif.gif");
			selectImage(cropImage);
			close();
			}
			
		}
	close("*");
    }
    close("*");
}
		
    
}