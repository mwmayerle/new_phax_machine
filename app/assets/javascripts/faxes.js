// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

// $(document).ready(function() {
// 	addAdditionalFileInput();
// 	// closeFileDropWindow();
// 	adjustAttachmentCount();
// });

// function adjustAttachmentCount() {
// 	let files = $(".file-counter");
// 	let filesArray = $.makeArray(files).reverse(); // .reverse() doesn't work on a jQuery object
// 	filesArray.forEach(function(fileLabel) {
// 		$(fileLabel).text("File: " + (filesArray.indexOf(fileLabel) + 1))
// 	});
// }

// function addAdditionalFileInput() {
// 	$("#send-another").on("click", function(event) {
// 		if ($(".file-attachments :file").val() === "") {
// 			FileDrop.removeEventListener('dragenter', handleDragEnter);
// 	    FileDrop.removeEventListener('dragover', handleDragOver);
// 	    FileDrop.removeEventListener('drop', handleDrop);
// 	    FileDrop.removeEventListener('dragleave', handleDragLeave);
// 	    FileDrop.registerAll();
// 		} else {
// 		fileCounter += 1;
// 			$("#all-files").prepend(
// 				"<div class='form-group file-attachments'>" +
// 				"<label class='file-counter'>File " + fileCounter + ":</label>" +
// 					"<div class='file-drop' data-target='#faxFile" + fileCounter + "'>" +
// 						"<button type='button' class='close' data-dismiss='#faxfile" + fileCounter + "' aria-label='Close'>" + 
// 							"<span>&times;</span>" +
// 						"</button>" +
// 						"<h3>Drag a file onto this box to upload it.</h3>" +
// 						"<input id='faxFile" + fileCounter + "' name='files[file" + fileCounter +"]' type='file' required>" +
// 					"</div>" +
// 					"<div class='faxFileProgress' hidden='hidden'></div>" +
// 				"</div>"
// 			);
// 		}
// 		adjustAttachmentCount();
// 	});
// }