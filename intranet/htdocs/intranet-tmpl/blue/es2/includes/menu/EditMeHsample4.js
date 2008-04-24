//--------------------------------------------------------------------------------------------------
// All material contained within this and associated downloaded pages is the property of 4thorder(TM) 
// Copyright © 2005.  All rights reserved.
//
// Author: Michael Falatine || Authors email: 4thorder@4thorder.us
//
// USAGE: You may use this script for commercial or personal use, however, the copyright is retained-
// by 4thorder (TM).
//
// For other free Scripts visit: http://www.4thorder.us/Scripts/
//---------------------------------------------------------------------------------------------------

// ||||||||||||||||
// | Basic Set-up  |
// ||||||||||||||||

// BRANCH CONTROL SETTINGS [Value MUST be in quotes]:
	// Enable single branch opening ONLY
	// Options: ['yes'=one branch at a time, ''=all branches will open]
	// Note: ALL Values other than 'yes' allows user to open more than one branch at a time
	var oneBranch='yes';

// EVENT TYPE SETTINGS [Value MUST be in quotes]:
	// Options:
	// 'mouseover'= branch expands when mouse is OVER <TH> element
	// 'click'=branch expands when <TH> element is clicked
	var handlerTYPE='mouseover';

// TRANSPARENCY SETTINGS (%) [Value MUST NOT be in qoutes]:
	var TValue=70;
		// 100=100% visible, 0=invisible [MUST BE  a number between 0 and 100]
		// Can be decimal (example: 70.5) or integer (example: 71)
		// Does not work in Opera

// IMAGE PLACEMENT [Value MUST be in quotes]:
	// Options:
	// 'before'=images will be inserted BEFORE content within <TH> element
	// 'after'=images will be inserted AFTER content within <TH> element
	// ''=images will NOT be included within <TH> element
	var ImagePlacement='after';


// |||||||||||||||||||||||
// | Define Images Here  |
// |||||||||||||||||||||||
// [Value MUST be in quotes]
// All images MUST be located in the folder "DMEImages"
// "DMEImages" folder MUST be located in SAME directory as the webpage that you want the menu to be on
// Note: Some images have been provided.  You may use provided, your own, or none.
// Sample images provided can be viewed in the "StartHere.htm" file

// SET [EXPAND] IMAGE FILE NAME:
	// Filenames of samples provided:
	// threedPLUS.gif | SimplePLUS.gif | thickBorderedPLUS.gif | thinBorderedPLUS.gif | bevArrowPLUS.gif
		
	var imagePLUS='plus.gif';

// SET [COLLAPSE] IMAGE FILE NAME:
	// Filenames of samples provided:
	// threedMINUS.gif | SimpleMINUS.gif | thickBorderedMINUS.gif | thinBorderedMINUS.gif | bevArrowMINUS.gif
		
	var imageMINUS	='min.gif';
