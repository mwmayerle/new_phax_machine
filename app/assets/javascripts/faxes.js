// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

$(document).ready(function() {
	function initialConfig() { 
		$("#send-another").prop("disabled", true);
	};

	addAdditionalFileInput(fileCounter);
	closeFileUploadWindow();
	adjustAttachmentCount(fileCounter);
	toggleAttachAnotherButton();
});
var fileCounter = 1;


function toggleAttachAnotherButton() {
	$(".file-attachments :file").change(function() {
		let $button = $("#send-another");
		if ($(".file-attachments :file").val() === "") {
			$button.prop("disabled", true);
			$button.addClass("disabled");
		} else {
			$button.prop("disabled", false);
			$button.removeClass("disabled");
		}
	});
};

function adjustAttachmentCount(fileCounter) {
	let files = $(".file-counter");
	let filesArray = $.makeArray(files)//.reverse(); // .reverse() doesn't work on a jQuery object
	filesArray.forEach(function(fileLabel) {
		$(fileLabel).text("File: " + (filesArray.indexOf(fileLabel) + 1))
	});
};

function closeFileUploadWindow(fileCounter) {
	$("#all-files").on("click", $(".close"), function(event) {
		if ($(event.target).parent().hasClass("close") || $(event.target).hasClass("close")) {
			$(event.target).closest(".file-attachments").remove();
		}
	adjustAttachmentCount(fileCounter);
	// FileDrop.registerAll();
	fileCounter -= 1;
	});
};

function addAdditionalFileInput(fileCounter) {
	$("#send-another").on("click", function(event) {
		// if ($(".file-attachments :file").val() === "") {
		// 	FileDrop.removeEventListener('dragenter', handleDragEnter);
	 //    FileDrop.removeEventListener('dragover', handleDragOver);
	 //    FileDrop.removeEventListener('drop', handleDrop);
	 //    FileDrop.removeEventListener('dragleave', handleDragLeave);
	 //    FileDrop.registerAll();
		// } else {
			if (fileCounter < 10) {
				fileCounter += 1;
				$("#all-files").append(
					"<div class='information-box file-attachments'>" +
						"<div class='row inline-input-margin'>" +
							"<div id='file" + fileCounter + "' class='form-group col'>" +
							"<label class='file-counter'>File " + fileCounter + ":</label>" +
								"<div class='file-drop' data-target='#faxFile" + fileCounter + "'>" +
									"<button type='button' class='close pull-right' data-dismiss='#faxfile" + fileCounter + "' aria-label='Close'>" + 
										"<span>&times;</span>" +
									"</button>" +
									// "<h3>Drag a file onto this box to upload it.</h3>" +
									"<input id='faxFile" + fileCounter + "' name='fax[files][file" + fileCounter +"]' type='file' required>" +
								"</div>" +
							// "<div class='faxFileProgress' hidden='hidden'></div>" +
							"</div>" +
						"</div>" +
					"</div>"
					);
				adjustAttachmentCount(fileCounter);
			}
		// }
	});
};