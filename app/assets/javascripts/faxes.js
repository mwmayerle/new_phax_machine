$(document).ready(() => {
	addUploadedFile();
	removeUploadedFile();
	dragOverColorChange();
	dragLeaveColorChange();
});

function dragOverColorChange() {
	$(".drag-drop-input").on('dragover', (event) => {
		$(event.target).css('background-color', '#e0e0e0')
	});
};

function dragLeaveColorChange() {
	$(".drag-drop-input").on('dragleave', (event) => {
		$(event.target).css('background-color', '#fafafa')
	});
};

var fileCounter = 1;

function addUploadedFile() {
	$("#all-files").change((event) => {
		if ($(".close-button").length < 10) {
			$(".added-files").append(
				`<tr id='faxFile${fileCounter}tr'>
					<td>
						<button class='close-button btn btn-sm btn-danger'>
							<i class="fa fa-trash-o" aria-hidden="false"></i>
						</button>
						${event.target.files[0].name}
					</td>
				</tr>`
			);

			$(`#faxFile${fileCounter}`).hide();
			fileCounter += 1;

			$("#all-files").append(
				`<div id='faxFile${fileCounter}' class="form-group col-lg-8 files">
					<input type='file' id='file${fileCounter}' class='drag-drop-input' name='fax[files][file${fileCounter}]'>
				</div>`
			);

		} else {
			console.log('farts')
			createAlert('danger', 'A maximum of 10 files per fax can be attached.')
		}
	});
};

function removeUploadedFile() {
	$(".added-files").on('click', $("tbody"), (event) => {
		let $button = $(event.target);
		if ($button.hasClass("close-button") || $button.hasClass("fa fa-trash-o")) {
			let $inputDivToDelete = $button.closest("tr").attr("id").slice(0, -2);
			$button.closest("tr").remove();
			$(`#${$inputDivToDelete}`).remove();
		}
	});
};