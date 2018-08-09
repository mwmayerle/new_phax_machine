phaxMachine.pages['fax-logs'] = {

	render: function() {

		organizationOptions = $("#org-select option"),
		userOptions = $("#user-select option"),
		faxNumberOptions = $("#fax-select option"),
		
		$.getJSON("/fax_logs", {}, function(response) {
			if (response) { // Each permission has different amounts of data
				$("#load-icon").hide();
				if ($('th').length === 8) {
					buildTableRowsAdmin(response);
				} else if ($('th').length === 7) {
					buildTableRowsManager(response);
				} else {
					buildTableRowsUser(response);
				}
			}
		});

		$("#org-select").change((event) => {
			event.stopPropagation();

			let organizationClass = $("#org-select option:selected").attr('class');
			let $faxSelect = $("#fax-select");
			let $orgSelect = $("#org-select");

			$faxSelect.empty();

			if (organizationClass === "all-org") {
				$orgSelect.empty();
				restoreSelectTag(organizationOptions, $orgSelect);
				restoreSelectTag(faxNumberOptions, $faxSelect);

			} else {
			 	$faxSelect.append(`<option class="all-linked" name="fax_log[fax_number]" value="all-linked">All Linked Numbers</option>`);
				createSelectTagWithConditional(faxNumberOptions, $faxSelect, organizationClass);
			 	$("#fax-select option").first().prop('selected', 'selected');
			}
		});

		$("#fax-select").change((event) => {
			event.stopPropagation();
			let organizationClass = $("#org-select option:selected").attr('class');
			let faxNumberClass = $("#fax-select option:selected").attr('class');
			let userClass = $("#user-select option:selected").attr('class');
			let $faxSelect = $("#fax-select");
			let $userSelect = $("#user-select");
			let $orgSelect = $("#org-select");

			switch(faxNumberClass) {
				case userClass === "all-user":
					$(userSelect).empty();
					createSelectTagMultipleConditionals(userOptions, $userSelect, [faxNumberClass, 'all-user']);
					$userSelect.append(`<option class="all-linked" name="fax_log[user]" value="all-linked">All Linked Users</option>`);
					selectDesiredOption(desiredOptionId, userOptions)
					$("#user-select option").first(userSelectedClass).prop('selected', 'selected');
					break;
			}
		});

		$('.datepicker-inline').datepicker({
	    dateFormat: 'mm-dd-yy',
	    endDate: '+0d',
	    autoclose: true,
	    maxDate: (0),
	  }),
		$('#end-date-field').val(getTodaysFormattedDate());

	}
};

function getTodaysFormattedDate () {
	let today = new Date();
	let dd = today.getDate();
	let mm = today.getMonth() + 1; // January is 0
	let yyyy = today.getFullYear();

	if (dd<10) { dd = `0${dd}` }
	if (mm<10) { mm = `0${mm}` } 

	return `${mm}-${dd}-${yyyy}`;
};

function buildTableRows(faxData) {
		let sentIcon = `<i style="color:green" class="fa fa-fw fa-arrow-circle-right" aria-hidden="true"></i>`;
		let receivedIcon = `<i style="color:darkblue" class="fa fa-fw fa-arrow-circle-left" aria-hidden="true"></i>`;
		let $tableBody = $("tbody");
		Object.keys(faxData).forEach((faxDatum) => {
			if (faxData[faxDatum].sent_by === undefined) {
				faxData[faxDatum].sent_by = "";
			};
			$tableBody.prepend(`
				<tr>
				<td class="text-center">
					${ (faxData[faxDatum].direction === "Sent") ? sentIcon : receivedIcon }
				</td>
			`);
			if ($('th').length === 8) { // Admin has the most <th>'s'
				$tableBody.prepend(`
					<td class="text-center">${faxData[faxDatum].organization}</td>
					<td class="text-center">${faxData[faxDatum].sent_by}</td>
				`);
			}
			if ($('th').length === 7) {
				$tableBody.prepend(`
					<td class="text-center">${faxData[faxDatum].organization}</td>
				`);	
			}
			$tableBody.prepend(`
				<td class="text-center">${faxData[faxDatum].from_number}</td>
				<td class="text-center">${faxData[faxDatum].to_number}</td>
				<td class="text-center status">${faxData[faxDatum].status}</td>
				<td class="text-center">${faxData[faxDatum].created_at}</td>
				<td class="text-center"><i class="fa fa-fw fa-download" aria-hidden="true"></i></td>
			</tr>
			`);
		});
		changeStatusColor();
	};

function buildTableRowsAdmin (faxData) {
	let sentIcon = `<i style="color:green" class="fa fa-fw fa-arrow-circle-right" aria-hidden="true"></i>`;
	let receivedIcon = `<i style="color:darkblue" class="fa fa-fw fa-arrow-circle-left" aria-hidden="true"></i>`;
	$("tbody").empty(); // Clears loading message

	Object.keys(faxData).forEach((faxDatum) => {
		if (faxData[faxDatum].sent_by === undefined) {
			faxData[faxDatum].sent_by = "";
		};
		$("tbody").prepend(`
			<tr>
				<td class="text-center">
					${(faxData[faxDatum].direction === "Sent") ? sentIcon : receivedIcon}
				</td>
				<td class="text-center">${faxData[faxDatum].organization}</td>
				<td class="text-center">${faxData[faxDatum].sent_by}</td>
				<td class="text-center">${faxData[faxDatum].from_number}</td>
				<td class="text-center">${faxData[faxDatum].to_number}</td>
				<td class="text-center status">${faxData[faxDatum].status}</td>
				<td class="text-center">${faxData[faxDatum].created_at}</td>
				<td class="text-center"><i class="fa fa-fw fa-download" aria-hidden="true"></i></td>
			</tr>
		`);
	});
	changeStatusColor();
};

function buildTableRowsManager(faxData) {
	let sentIcon = `<i style="color:green" class="fa fa-fw fa-arrow-circle-right" aria-hidden="true"></i>`;
	let receivedIcon = `<i style="color:darkblue" class="fa fa-fw fa-arrow-circle-left" aria-hidden="true"></i>`;

	Object.keys(faxData).forEach((faxDatum) => {
		if (faxData[faxDatum].sent_by === undefined) {
			faxData[faxDatum].sent_by = "";
		};
		$("tbody").prepend(`
			<tr>
				<td class="text-center">
					${ (faxData[faxDatum].direction === "Sent") ? sentIcon : receivedIcon }
				</td>
				<td class="text-center">${faxData[faxDatum].sent_by}</td>
				<td class="text-center">${faxData[faxDatum].from_number}</td>
				<td class="text-center">${faxData[faxDatum].to_number}</td>
				<td class="text-center status">${faxData[faxDatum].status}</td>
				<td class="text-center">${faxData[faxDatum].created_at}</td>
				<td class="text-center"><i class="fa fa-fw fa-download" aria-hidden="true"></i></td>
			</tr>
		`);
	});
	changeStatusColor();
};

function buildTableRowsUser(faxData) {
	let sentIcon = `<i style="color:green" class="fa fa-fw fa-arrow-circle-right" aria-hidden="true"></i>`;
	let receivedIcon = `<i style="color:darkblue" class="fa fa-fw fa-arrow-circle-left" aria-hidden="true"></i>`;

	Object.keys(faxData).forEach((faxDatum) => {
		if (faxData[faxDatum].sent_by === undefined) {
			faxData[faxDatum].sent_by = "";
		};
		$("tbody").prepend(`
			<tr>
				<td class="text-center">
					${ (faxData[faxDatum].direction === "Sent") ? sentIcon : receivedIcon }
				</td>
				<td class="text-center">${faxData[faxDatum].from_number}</td>
				<td class="text-center">${faxData[faxDatum].to_number}</td>
				<td class="text-center status">${faxData[faxDatum].status}</td>
				<td class="text-center">${faxData[faxDatum].created_at}</td>
				<td class="text-center"><i class="fa fa-fw fa-download" aria-hidden="true"></i></td>
			</tr>
		`);
	});
	changeStatusColor();
};

function changeStatusColor() {
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
		}
	});
};


function restoreSelectTag(originalTagData, tagBeingRestored) {
	$.each(originalTagData, function() { tagBeingRestored.append($(this)); });
};

function createSelectTagMultipleConditionals(originalTagData, tagBeingRestored, addIfClasses) {
	addIfClasses.forEach((addIfClass) => {
		$.each(originalTagData, function() {
			if ($(this).hasClass(addIfClass)) { tagBeingRestored.append($(this)); }
		});
	});
};

function createSelectTagWithConditional(originalTagData, tagBeingRestored, addIfClass) {
	$.each(originalTagData, function() {
		if ($(this).hasClass(addIfClass)) { tagBeingRestored.append($(this)); }
	});
};

function selectDesiredOption(desiredOptionId, options) {
	$.each(options, function() {
		if ($(this).attr('id') === desiredOptionId) { $(this).prop('selected', 'selected'); }
	});
}

		// function faxSelectOnChange() {
		// 	$("#fax-select").change((event) => {
		// 		event.stopPropagation();

		// 		let faxNumberClass = $("#fax-select option:selected").attr('class');
		// 		let userClass = $("#user-select option:selected").attr('class');
		// 		let orgClass = $("#org-select option:selected").attr('class');

		// 		let $orgSelect = $("#org-select");
		// 		let $userSelect = $("#user-select");
		// 		let $faxSelect = $("#fax-select");

		// 		if (faxNumberClass === orgClass && faxNumberClass === userClass) {
		// 			$userSelect.empty();
		// 			$orgSelect.empty();

		// 			let userSelectedClass = $("#user-select option:selected").attr('class');
		// 			let orgSelectedClass = $("#org-select option:selected").attr('class');

		// 			createSelectTagMultipleConditionals(userOptions, $userSelect, [faxNumberClass, 'all-user']);
		// 			$userSelect.append(`<option class="all-linked" name="fax_log[user]" value="all-linked">All Linked Users</option>`);
		// 			$("#user-select option").first(userSelectedClass).prop('selected', 'selected');

		// 			createSelectTagMultipleConditionals(organizationOptions, $orgSelect, [faxNumberClass, 'all-org']);
		// 			$("#org-select option").first(orgSelectedClass).prop('selected', 'selected');

		// 		} else if (faxNumberClass === 'all-fax') {
		// 			$userSelect.empty();
		// 			$orgSelect.empty();

		// 			restoreSelectTag(organizationOptions, $orgSelect);
		// 			restoreSelectTag(userOptions, $userSelect);

		// 			$faxSelect.empty();
		// 			restoreSelectTag(faxNumberOptions, $faxSelect);

		// 		} else if (orgClass === 'all-org' && userClass === undefined) {
		// 			let orgSelectedClass = $("#org-select option:selected").attr('class');
		// 			$orgSelect.empty();
		// 			createSelectTagMultipleConditionals(organizationOptions, $orgSelect, [faxNumberClass, 'all-org']);
		// 			$("#org-select option").first(orgSelectedClass).prop('selected', 'selected');

		// 		} else if (faxNumberClass === 'all-linked') {
		// 			// do nothing

		// 		} else if (orgClass === 'all-org') {
		// 			$userSelect.empty();
		// 			$orgSelect.empty();
					
		// 			let faxSelectedId = $("#fax-select option:selected").attr('id');

		// 			$faxSelect.empty();
		// 			createSelectTagMultipleConditionals(faxNumberOptions, $faxSelect, [faxNumberClass, 'all-fax']);
		// 			$("#fax-select option").first(faxSelectedId).prop('selected', 'selected');

		// 			createSelectTagMultipleConditionals(organizationOptions, $orgSelect, [faxNumberClass, 'all-org']);
		// 			$("#org-select option").first().prop('selected', 'selected');

		// 			$userSelect.append(`<option class="all-linked" name="fax_log[user]" value="all-linked">All Linked Users</option>`);
		// 			createSelectTagMultipleConditionals(userOptions, $userSelect, [faxNumberClass, 'all-user']);
		// 			$("#user-select option").first().prop('selected', 'selected');

		// 		} else if (faxNumberClass !== 'all-linked' && orgClass === undefined ) {
		// 			$userSelect.empty();
		// 			$orgSelect.empty();
		// 			let faxSelectedId = $("#fax-select option:selected").attr('id');
					
		// 			$userSelect.append(`<option class="all-linked" name="fax_log[user]" value="all-linked">All Linked Users</option>`);
		// 			createSelectTagMultipleConditionals(userOptions, $userSelect, [faxNumberClass, 'all-user']);
		// 			$("#user-select option").first().prop('selected', 'selected');

		// 			createSelectTagMultipleConditionals(organizationOptions, $orgSelect, [faxNumberClass, 'all-org']);
		// 			$("#org-select option").first().prop('selected', 'selected');

		// 			$faxSelect.empty();
		// 			createSelectTagMultipleConditionals(faxNumberOptions, $faxSelect, [faxNumberClass, 'all-fax']);
		// 			$.each($("#fax-select option"), function() {
		// 				if ($(this).attr('id') === faxSelectedId) {
		// 					$(this).prop('selected', 'selected');
		// 					return;
		// 				}
		// 			});
					
		// 		} else if (faxNumberClass !== 'all-linked') {
		// 			let faxSelectedId = $("#fax-select option:selected").attr('id');
		// 			$userSelect.empty();
		// 			$orgSelect.empty();
		// 			$faxSelect.empty();

		// 			$userSelect.append(`<option class="all-linked" name="fax_log[user]" value="all-linked">All Linked Users</option>`);
		// 			createSelectTagMultipleConditionals(userOptions, $userSelect, [faxNumberClass, 'all-user']);
		// 			$("#user-select option").first().prop('selected', 'selected');

		// 			createSelectTagMultipleConditionals(organizationOptions, $orgSelect, [faxNumberClass, 'all-org']);
		// 			$("#org-select option").first().prop('selected', 'selected');

		// 			$faxSelect.append(`<option class="all-linked" name="fax_log[fax]" value="all-linked">All Linked Numbers</option>`);
		// 			createSelectTagMultipleConditionals(faxNumberOptions, $faxSelect, [faxNumberClass, 'all-fax']);
		// 			$.each($("#fax-select option"), function() {
		// 				if ($(this).attr('id') === faxSelectedId) { $(this).prop('selected', 'selected'); }
		// 			});
		// 		}
		// 	});
		// },

		// userSelectOnChange: function() {
		// 	$("#user-select").change((event) => {
		// 		event.stopPropagation();

		// 		let orgClass = $("#org-select option:selected").attr('class');
		// 		let faxNumClass = $("#fax-select option:selected").attr('class');
		// 		let userClass = $("#user-select option:selected").attr('class');

		// 		let $faxSelect = $("#fax-select");
		// 		let $orgSelect = $("#org-select");

		// 		if (userClass === 'all-linked') {
		// 			// do nothing
		// 		} else if (userClass === faxNumClass) {
		// 			$orgSelect.empty();
		// 			createSelectTagMultipleConditionals(organizationOptions, $orgSelect, [userClass, 'all-org']);
		// 			$("#org-select option").first().prop('selected', 'selected');

		// 		} else if (userClass === 'all-user') {
		// 			$orgSelect.empty();
		// 			restoreSelectTag(organizationOptions, $orgSelect);
		// 			$faxSelect.empty();
		// 			restoreSelectTag(faxNumberOptions, $faxSelect);

		// 		}	else if (userClass !== 'all-linked') {
		// 			$orgSelect.empty();
		// 			createSelectTagMultipleConditionals(organizationOptions, $orgSelect, [userClass, 'all-org']);
		// 			$("#org-select option").first().prop('selected', 'selected');

		// 			$faxSelect.empty();
		// 			$faxSelect.append(`
		// 				<option class="all-linked" name="fax_log[fax_number]" value="all-linked">All Linked Numbers</option>
		// 			`);
		// 			createSelectTagMultipleConditionals(faxNumberOptions, $faxSelect, [userClass, 'all-fax']);
		// 			$("#fax-select option").first().prop('selected', 'selected');

		// 		} else if (faxNumClass !== 'all-linked' && orgClass === undefined ) {
		// 			$userSelect.empty();
		// 			restoreSelectTag(userOptions, $userSelect);
		// 		}
		// 	});
		// },
	// }
// }