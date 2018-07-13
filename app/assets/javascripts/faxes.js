// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

$(document).ready(function() {
	$("#send-another").prop("disabled", true);
	addAdditionalFileInput();
	closeFileUploadWindow();
	adjustAttachmentCount();
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

function adjustAttachmentCount() {
	let files = $(".file-counter");
	let filesArray = $.makeArray(files)
	filesArray.forEach(function(fileLabel) {
		$(fileLabel).text("File: " + (filesArray.indexOf(fileLabel) + 1))
	});
};

function closeFileUploadWindow() {
	$("#all-files").on("click", $(".close"), function(event) {
		if ($(event.target).parent().hasClass("close") || $(event.target).hasClass("close")) {
			$(event.target).closest(".file-attachments").remove();
		}
	adjustAttachmentCount();
	// FileDrop.registerAll();
	fileCounter -= 1;
	});
};

function addAdditionalFileInput() {
	$("#send-another").on("click", function(event) {
		// if ($(".file-attachments :file").val() === "") {
		// 	FileDrop.removeEventListener('dragenter', handleDragEnter);
	 //    FileDrop.removeEventListener('dragover', handleDragOver);
	 //    FileDrop.removeEventListener('drop', handleDrop);
	 //    FileDrop.removeEventListener('dragleave', handleDragLeave);
	 //    FileDrop.registerAll();
		// } else {
			if ($(".file-attachments :file").length < 10) {
				fileCounter += 1;
				$("#all-files").append(
					"<div class='information-box file-attachments'>" +
						"<div class='row inline-input-margin'>" +
							"<div id='file" + fileCounter + "' class='form-group col'>" +
								"<button type='button' class='close' data-dismiss='#faxfile" + fileCounter + "' aria-label='Close'>" + 
									"<span class='the-x'>&times;</span>" +
								"</button>" +
								"<label class='file-counter'>File " + fileCounter + ":</label>" +
								"<div class='file-drop' data-target='#faxFile" + fileCounter + "'>" +
									// "<h3>Drag a file onto this box to upload it.</h3>" +
									"<input id='faxFile" + fileCounter + "' name='fax[files][file" + fileCounter +"]' type='file' required>" +
								"</div>" +
							// "<div class='faxFileProgress' hidden='hidden'></div>" +
							"</div>" +
						"</div>" +
					"</div>"
					);
				adjustAttachmentCount();
			}
		// }
	});
};