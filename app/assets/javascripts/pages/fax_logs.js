/////////////////////////////////////////////////////////////////////////////////
//  SEE CREATE.JS.ERB IN THE FAX_LOGS VIEW FOLDER FOR ADDITIONAL JS FUNCTIONS  //
/////////////////////////////////////////////////////////////////////////////////

phaxMachine.pages['fax-logs'] = {

	render: function() {

		organizationOptions = $("#org-select option"),
		userOptions = $("#user-select option"),
		faxNumberOptions = $("#fax-select option"),
		currentPageNumber = 1;
		backButtonText = '<';
		forwardButtonText = '>';
		endButtonText = '>>';
		beginningButtonText = '<<';

		$("#load-icon").hide();

		$("#filter-button").on('click', function(event) {
			$("tbody").empty();
			$("#pagination-ul").empty();
			$("#load-icon").show();
		});

	 $('.datepicker-inline').flatpickr({
    	enableTime: true,
    	dateFormat: 'Y-m-d h:iK',
    	altInput: true,
    	altFormat: 'm-d-Y h:i K',
	    maxDate: new Date(),
	    autoclose: true
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
				createSelectTagMultipleConditionals(faxNumberOptions, $faxSelect, [organizationClass, 'all-fax']);
			 	$("#fax-select option").first().prop('selected', 'selected');
			}
		});

		$("#fax-select").change((event) => {
			event.stopPropagation();

			let organizationClass = $("#org-select option:selected").attr('class');
			let faxNumberClass = $("#fax-select option:selected").attr('class');
			let userClass = $("#user-select option:selected").attr('class');
			let $userSelect = $("#user-select");
			let $orgSelect = $("#org-select");

			if (userClass === 'all-user') {
				let = desiredOptionId = $("#user-select option:selected").attr('id');
				$($userSelect).empty();
				$userSelect.append(`<option class="all-linked" name="fax_log[user]" value="all-linked">All Linked Users</option>`);
				createSelectTagMultipleConditionals(userOptions, $userSelect, [faxNumberClass, 'all-user']);
				$("#user-select option").first().prop('selected', 'selected');
			} else if (userClass === 'all-linked' || faxNumberClass === 'all-linked') {
				// do nothing
			} else if (faxNumberClass === 'all-fax') {
				$($orgSelect).empty();
				restoreSelectTag(organizationOptions, $orgSelect);
			} else if (organizationClass === 'all-org' || faxNumberClass !== organizationClass) {
				$($orgSelect).empty();
				createSelectTagMultipleConditionals(organizationOptions, $orgSelect, [faxNumberClass, 'all-org']);
				$("#org-select option").first().prop('selected', 'selected');
			}
		});

		$("#user-select").change((event) => {
			event.stopPropagation();

			let userClass = $("#user-select option:selected").attr('class');
			let $userSelect = $("#user-select");
			let $faxSelect = $("#fax-select");

			if (userClass === "all-user") {
				$faxSelect.empty();
				$($userSelect).empty();
				restoreSelectTag(faxNumberOptions, $faxSelect);
				restoreSelectTag(userOptions, $userSelect);
			}
		});
		changeStatusColor();
	}
};

function buildTableRows(faxData, pageNumberDisplay) {
	let sentIcon = `<i style="color:green" class="fa fa-fw fa-arrow-circle-right" aria-hidden="true"></i>`;
	let receivedIcon = `<i style="color:darkblue" class="fa fa-fw fa-arrow-circle-left" aria-hidden="true"></i>`;

	Object.keys(faxData).forEach((faxDatum) => {
		if (faxData[faxDatum]['page'] === pageNumberDisplay) {

			if (faxData[faxDatum].organization === undefined) { faxData[faxDatum].organization = "N/A"; };
			if (faxData[faxDatum].sent_by === undefined) { faxData[faxDatum].sent_by = ""; };
			if (faxData[faxDatum].from_number === undefined) { faxData[faxDatum].from_number = "Released Number"; };
			if (faxData[faxDatum].to_number === undefined) { faxData[faxDatum].to_number = "Released Number"; };

			let head = `<tr>
				<td class="text-center"> ${ (faxData[faxDatum].direction === "Sent") ? sentIcon : receivedIcon } </td>`;
			// Admin has 8 <th>, Manager has 7 <th>, User has only 6. These if blocks add/remove data for these permission levels
				if ($('#fax-log-table th').length === 8) { head = head.concat('', `<td class="text-center">${faxData[faxDatum].organization}</td>`); }
				if ($('#fax-log-table th').length > 6) { head = head.concat('', `<td class="text-center">${faxData[faxDatum].sent_by}</td>`); }

			head = head.concat('', `
				<td class="text-center">${faxData[faxDatum].from_number}</td>
				<td class="text-center">${faxData[faxDatum].to_number}</td>
				<td class="status">${faxData[faxDatum].status}</td>
				<td class="text-center">${faxData[faxDatum].created_at}</td>
				<td class="text-center"><i class="fa fa-fw fa-download" aria-hidden="true"></i></td>
			</tr>
			`);
			$("tbody").prepend(head);
		}
	});
	changeStatusColor();
};

function changeStatusColor() {
	$.each($('.status'), function() { // $(this) is the entire <td> tag within the $.each()
		switch($(this).text()) {
			case 'Success': // These statuses are capitalized unlike the normal API response b/c Ruby's 'titleize() is used in FaxLog model'
				$(this).prepend(`
					<span style='color:limegreen'>&nbsp;<i style='font-size:10px' class="fa fa-fw fa-circle"></i>&nbsp;</span>
				`);
				break;
			case 'Queued':
				$(this).prepend(`
					<span style='color:darkgrey'>&nbsp;<i style='font-size:10px' class="fa fa-fw fa-circle"></i>&nbsp;</span>
				`);
				break;
			case 'Inprogress':
				$(this).text('In Progress');
				$(this).prepend(`
					<span style='color:darkblue'>&nbsp;<i style='font-size:10px' class="fa fa-fw fa-circle"></i>&nbsp;</span>
				`)
				break;
			case 'Failure':
				$(this).prepend(`
					<span style='color:crimson'>&nbsp;<i style='font-size:10px' class="fa fa-fw fa-circle"></i>&nbsp;</span>
				`);
				break;
			case 'Partialsuccess':
				$(this).text('Partial Success')
				$(this).prepend(`
					<span style='color:darkorange'>&nbsp;<i style='font-size:10px' class="fa fa-fw fa-circle"></i>&nbsp;</span>
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

function paginateFaxes(apiResponse) {
	let pageNumber = 0;
	let counter = 1;
	let $pageNumberList = $("#pagination-ul");

	addPreviousSymbol($pageNumberList, currentPageNumber, beginningButtonText);
	addPreviousSymbol($pageNumberList, currentPageNumber, backButtonText);

	Object.keys(apiResponse).forEach((key, counter) => {
		if (counter % 20 === 0) { 
			pageNumber += 1;
			addPageNumber($pageNumberList, pageNumber, currentPageNumber);
		}
		apiResponse[key]['page'] = pageNumber;
	});

	addNextSymbol($pageNumberList, pageNumber, currentPageNumber, forwardButtonText);
	addNextSymbol($pageNumberList, pageNumber, currentPageNumber, endButtonText);
};

function addPageNumber($pageNumberList, pageNumber, currentPageNumber) {
	if (pageNumber === currentPageNumber) {
		$pageNumberList.append(`<li id="${pageNumber}" class="page-item active"><a class="page-link" href="#">${pageNumber}</a></li>`);
	} else {
		$pageNumberList.append(`<li id="${pageNumber}" class="page-item"><a class="page-link" href="#">${pageNumber}</a></li>`);
	}
};

function addPreviousSymbol($pageNumberList, currentPageNumber, symbolToAdd) {
	if (currentPageNumber === 1) {
		$pageNumberList.append(`<li class="page-item disabled"><a class="page-link" href="#">${symbolToAdd}</a></li>`);
	} else {
		$pageNumberList.append(`<li class="page-item"><a class="page-link" href="#">${symbolToAdd}</a></li>`);
	}
};

function addNextSymbol($pageNumberList, pageNumber, currentPageNumber, symbolToAdd) {
	if (pageNumber === currentPageNumber) {
		$pageNumberList.append(`<li class="page-item disabled"><a class="page-link" href="#">${symbolToAdd}</a></li>`);
	} else {
		$pageNumberList.append(`<li class="page-item"><a class="page-link" href="#">${symbolToAdd}</a></li>`);
	}
};