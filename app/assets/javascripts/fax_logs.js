var userOptions;
var faxNumberOptions;
var organizationOptions;

$(document).ready(() => {
	// Will be used to rebuild HTML select/option tags
	faxNumberOptions = $("#fax-select option");
	organizationOptions = $("#org-select option");
	userOptions = $("#user-select option");
});

var loadDatePicker = function() {
	$('.datepicker-inline').datepicker({
    dateFormat: 'mm-dd-yy',
    endDate: '+0d',
    autoclose: true,
    maxDate: (0),
  });
	$('#end-date-field').val(getTodaysFormattedDate());
};

function getTodaysFormattedDate() {
	let today = new Date();
	let dd = today.getDate();
	let mm = today.getMonth() + 1; // January is 0
	let yyyy = today.getFullYear();

	if (dd<10) { dd = `0${dd}` }
	if (mm<10) { mm = `0${mm}` } 

	return `${mm}-${dd}-${yyyy}`;
};

function restoreSelectTag(originalTagData, tagBeingRestored) {
	$.each(originalTagData, function() {
		tagBeingRestored.append($(this));
	});
};

function createSelectTagMultipleConditionals(originalTagData, tagBeingRestored, addIfClasses) {
	addIfClasses.forEach((addIfClass) => {
		$.each(originalTagData, function() {
			if ($(this).hasClass(addIfClass)) {
				tagBeingRestored.append($(this));
			}
		});
	})
};

function createSelectTagWithConditional(originalTagData, tagBeingRestored, addIfClass) {
	$.each(originalTagData, function() {
		if ($(this).hasClass(addIfClass)) {
			tagBeingRestored.append($(this));
		}
	});
};

var faxSelectOnChange = function() {
	$("#fax-select").change((event) => {
		event.stopPropagation();

		let faxNumberClass = $("#fax-select option:selected").attr('class');
		let userClass = $("#user-select option:selected").attr('class');
		let orgClass = $("#org-select option:selected").attr('class');

		let $orgSelect = $("#org-select");
		let $userSelect = $("#user-select");
		let $faxSelect = $("#fax-select");

		$userSelect.empty();
		$orgSelect.empty();

		if (faxNumberClass === orgClass && faxNumberClass === userClass) {
			console.log('1')
			let userSelectedClass = $("#user-select option:selected").attr('class');
			let orgSelectedClass = $("#org-select option:selected").attr('class');

			createSelectTagMultipleConditionals(userOptions, $userSelect, [faxNumberClass, 'all-user']);
			$userSelect.append(`<option class="all-linked" name="fax_log[user]" value="all-linked">All Linked Users</option>`);
			$("#user-select option").first(userSelectedClass).prop('selected', 'selected');

			createSelectTagMultipleConditionals(organizationOptions, $orgSelect, [faxNumberClass, 'all-org']);
			$("#org-select option").first(orgSelectedClass).prop('selected', 'selected');

		} else if (faxNumberClass === 'all-fax') {
			console.log('2')
			restoreSelectTag(organizationOptions, $orgSelect);
			restoreSelectTag(userOptions, $userSelect);

			$faxSelect.empty();
			restoreSelectTag(faxNumberOptions, $faxSelect);

		} else if (orgClass === 'all-org' || userClass !== 'all-user') {
			console.log('3')
			// this variable is defined here b/c ES6 'let' isolates it to the 'else if' block it's defined within
			let faxSelectedClass = $("#fax-select option:selected").attr('class');

			$faxSelect.empty();
			createSelectTagMultipleConditionals(faxNumberOptions, $faxSelect, [faxNumberClass, 'all-fax']);
			$("#fax-select option").first(faxSelectedClass).prop('selected', 'selected');

			createSelectTagMultipleConditionals(organizationOptions, $orgSelect, [faxNumberClass, 'all-org']);
			$("#org-select option").first().prop('selected', 'selected');

			$userSelect.append(`<option class="all-linked" name="fax_log[user]" value="all-linked">All Linked Users</option>`);
			createSelectTagMultipleConditionals(userOptions, $userSelect, [faxNumberClass, 'all-user']);
			$("#user-select option").first().prop('selected', 'selected');

		} else if (faxNumberClass !== 'all-linked' && orgClass === undefined ) {
			console.log('hi I AM WORKING ON THIS BLOCK WITH A MANAGER LOGGED IN BE SURE TO CHECK USER AS WELL')
			let faxSelectedClass = $("#fax-select option:selected").attr('class');
			
			$userSelect.append(`<option class="all-linked" name="fax_log[user]" value="all-linked">All Linked Users</option>`);
			createSelectTagMultipleConditionals(userOptions, $userSelect, [faxNumberClass, 'all-user']);
			$("#user-select option").first().prop('selected', 'selected');

			createSelectTagMultipleConditionals(organizationOptions, $orgSelect, [faxNumberClass, 'all-org']);
			$("#org-select option").first().prop('selected', 'selected');

			$faxSelect.empty();
			createSelectTagMultipleConditionals(faxNumberOptions, $faxSelect, [faxNumberClass, 'all-fax']);
			$("#fax-select option").first(faxSelectedClass).prop('selected', 'selected');
			
		} else if (faxNumberClass !== 'all-linked') {
			let faxSelectedClass = $("#fax-select option:selected").attr('class');
			
			createSelectTagMultipleConditionals(userOptions, $userSelect, [faxNumberClass, 'all-user']);

			createSelectTagMultipleConditionals(organizationOptions, $orgSelect, [faxNumberClass, 'all-org']);
			$("#org-select option").first().prop('selected', 'selected');

			$faxSelect.empty();
			createSelectTagMultipleConditionals(faxNumberOptions, $faxSelect, [faxNumberClass, 'all-fax']);
			$("#fax-select option").first(faxSelectedClass).prop('selected', 'selected');
		}
	});
};

var userSelectOnChange = function() {
	$("#user-select").change((event) => {
		event.stopPropagation();

		let faxNumClass = $("#fax-select option:selected").attr('class');
		let userClass = $("#user-select option:selected").attr('class');

		let $faxSelect = $("#fax-select");
		let $orgSelect = $("#org-select");

		$orgSelect.empty();

		if (userClass === faxNumClass) {
			createSelectTagMultipleConditionals(organizationOptions, $orgSelect, [userClass, 'all-org']);
			$("#org-select option").first().prop('selected', 'selected');

		} else if (userClass === 'all-user') {
			restoreSelectTag(organizationOptions, $orgSelect);

			$faxSelect.empty();
			restoreSelectTag(faxNumberOptions, $faxSelect);

		}	else if (userClass !== 'all-linked') {
			createSelectTagMultipleConditionals(organizationOptions, $orgSelect, [userClass, 'all-org']);
			$("#org-select option").first().prop('selected', 'selected');

			$faxSelect.empty();
			$faxSelect.append(`
				<option class="all-linked" name="fax_log[fax_number]" value="all-linked">All Linked Fax Numbers</option>
			`);
			createSelectTagMultipleConditionals(faxNumberOptions, $faxSelect, [userClass, 'all-fax']);
			$("#fax-select option").first().prop('selected', 'selected');

		} else if (faxNumberClass !== 'all-linked' && orgClass === undefined ) {
			$userSelect.empty();
			restoreSelectTag(userOptions, $userSelect);
		}
	});
};

var orgSelectOnChange = function() {
	$("#org-select").change((event) => {
		event.stopPropagation();

		let organizationClass = $("#org-select option:selected").attr('class');
		let $faxSelect = $("#fax-select");
		let $userSelect = $("#user-select");
		let $orgSelect = $("#org-select");

		$faxSelect.empty();
		$userSelect.empty();

		if (organizationClass === "all-org") {
			$orgSelect.empty();
			restoreSelectTag(organizationOptions, $orgSelect);
			restoreSelectTag(faxNumberOptions, $faxSelect);
			restoreSelectTag(userOptions, $userSelect);

		} else {
			$faxSelect.append(`<option class="all-linked" name="fax_log[fax_number]" value="all-linked">All Linked Fax Numbers</option>`);
			createSelectTagWithConditional(faxNumberOptions, $faxSelect, organizationClass);
			$("#fax-select option").first().prop('selected', 'selected');

			$userSelect.append(`<option class="all-linked" name="fax_log[user]" value="all-linked">All Linked Users</option>`);
			createSelectTagWithConditional(userOptions, $userSelect, organizationClass);
			$("#user-select option").first().prop('selected', 'selected');
		}
	});
};

var changeStatusColor = function() {
	$.each($('.status'), function() { // $(this) is the entire <td> tag within the $.each()
		switch($(this).text()) {
			case 'Success':
				$(this).prepend(`
					<span style='color:limegreen'>&nbsp;<i style='font-size:10px' class="fa fa-fw fa-circle"></i>&nbsp;&nbsp;</span>
				`);
				break;
			case 'Queued':
				$(this).prepend(`
					<span style='color:darkgrey'>&nbsp;<i style='font-size:10px' class="fa fa-fw fa-circle"></i>&nbsp;&nbsp;</span>
				`);
				break;
			case 'Inprogress':
				$(this).text('In Progress');
				$(this).prepend(`
					<span style='color:darkblue'>&nbsp;<i style='font-size:10px' class="fa fa-fw fa-circle"></i>&nbsp;&nbsp;</span>
				`)
				break;
			case 'Failure':
				$(this).prepend(`
					<span style='color:crimson'>&nbsp;<i style='font-size:10px' class="fa fa-fw fa-circle"></i>&nbsp;&nbsp;</span>
				`);
				break;
			case 'Partialsuccess':
				$(this).text('Partial Success')
				$(this).prepend(`
					<span style='color:darkorange'>&nbsp;<i style='font-size:10px' class="fa fa-fw fa-circle"></i>&nbsp;&nbsp;</span>
				`);
				break;
			case 'Pendingbatch':
				$(this).text('Pending Batch');
				$(this).prepend(`
					<span style='color:darkblue'>&nbsp;<i style='font-size:10px' class="fa fa-fw fa-circle"></i>&nbsp;&nbsp;</span>
				`);
				break;
		}
	});
};