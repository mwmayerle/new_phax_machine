const	backButtonText = '<';
const	forwardButtonText = '>';
const	endButtonText = '>>';
const	beginningButtonText = '<<';

phaxMachine.pages['fax-logs'] = {
	render: function() {
		currentPageNumber = 1;
		$("#load-icon").hide();

		$("#filter-button").on('click', function(event) {
			$("#no-initial-results").empty();
			$("tbody").empty();
			$("#pagination-ul").empty();
			$("#load-icon").show();
		});
		changeStatusColor();
		downloadCursorChange();
	}
};

function buildTableRows(faxData, pageNumberDisplay) {
	let sentIcon = `<i style="color:green" class="fa fa-fw fa-arrow-circle-right" aria-hidden="true"></i>`;
	let receivedIcon = `<i style="color:darkblue" class="fa fa-fw fa-arrow-circle-left" aria-hidden="true"></i>`;

	Object.keys(faxData).forEach((faxDatum) => {
		if (faxData[faxDatum]['page'] === pageNumberDisplay) {

			if (faxData[faxDatum].organization === undefined) { faxData[faxDatum].organization = ""; };
			if (faxData[faxDatum].sent_by === undefined) { faxData[faxDatum].sent_by = ""; };

			if (faxData[faxDatum].from_number === null) { faxData[faxDatum].from_number = "Restricted"; };

			if (faxData[faxDatum].from_number === undefined) { faxData[faxDatum].from_number = ""; };
			if (faxData[faxDatum].to_number === undefined) { faxData[faxDatum].to_number = ""; };

			let head = `<tr id="${faxDatum}">
				<td class="text-center"> ${ (faxData[faxDatum].direction === "Sent") ? sentIcon : receivedIcon } </td>`;
			// Admin has 8 <th>, Manager has 7 <th>, User has only 6. These if blocks add/remove data for these permission levels
				if ($('#fax-log-table th').length === 8) { head = head.concat('', `<td class="text-center">${faxData[faxDatum].organization}</td>`); }
				if ($('#fax-log-table th').length > 6) { head = head.concat('', `<td class="text-center">${faxData[faxDatum].sent_by}</td>`); }
			head = head.concat('', `
				<td class="text-center">${faxData[faxDatum].from_number}</td>
				<td class="text-center">${faxData[faxDatum].to_number}</td>
				<td class="status">${faxData[faxDatum].status}</td>
				<td class="text-center">${faxData[faxDatum].created_at}</td>
				<td class="text-center">`
				);
				if (faxData[faxDatum].status === "Success" || faxData[faxDatum].status === "Failure" || faxData[faxDatum].status === "Partial Success") {
					head = head.concat('', `
						<a href="/download/${faxDatum}"
							<i class="fa fa-fw fa-download" aria-hidden="true"></i>
						</a>`
						);
				}
				head = head.concat(`</td>
			</tr>
			`);
			$("tbody").prepend(head);
		}
	});
	changeStatusColor();
	downloadCursorChange();
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

function restoreSelectTag(originalTagData, tagBeingRestored) { $.each(originalTagData, function() { tagBeingRestored.append($(this)); }); };

function createSelectTagMultipleConditionals(originalTagData, tagBeingRestored, addIfClasses) {
	addIfClasses.forEach((addIfClass) => {
		$.each(originalTagData, function() { if ($(this).hasClass(addIfClass)) { tagBeingRestored.append($(this)); }});
	});
};

//////////////////////////////////////////////
////  functions below are for pagination  ////
//////////////////////////////////////////////

function paginateFaxes(apiResponse) {
	let pageNumber = 0;
	let counter = 1;
	let $pageNumberList = $("#pagination-ul");

	addPreviousSymbol($pageNumberList, currentPageNumber, beginningButtonText);
	addPreviousSymbol($pageNumberList, currentPageNumber, backButtonText);

	let highestPageNumber = addPageNumbersToResponse($pageNumberList, pageNumber, currentPageNumber);

	addNextSymbol($pageNumberList, highestPageNumber, currentPageNumber, forwardButtonText);
	addNextSymbol($pageNumberList, highestPageNumber, currentPageNumber, endButtonText);

	if (highestPageNumber > 18) { splitPagination(currentPageNumber, highestPageNumber); }
};

function addPageNumbersToResponse($pageNumberList, pageNumber, currentPageNumber) {
	Object.keys(apiResponse).forEach((key, counter) => {
		if (counter % 20 === 0) { 
			pageNumber += 1;
			addPageNumber($pageNumberList, pageNumber, currentPageNumber);
		}
		apiResponse[key]['page'] = pageNumber;
	});
	return pageNumber;
};

function addPageNumber($pageNumberList, pageNumber, currentPageNumber) {
	if (pageNumber === currentPageNumber) {
		$pageNumberList.append(`<li id="${pageNumber}" class="page-item active"><a class="page-link text-center" href="#">${pageNumber}</a></li>`);
	} else {
		$pageNumberList.append(`<li id="${pageNumber}" class="page-item"><a class="page-link text-center" href="#">${pageNumber}</a></li>`);
	}
};

function addPreviousSymbol($pageNumberList, currentPageNumber, symbolToAdd) {
	if (currentPageNumber === 1) {
		$pageNumberList.append(`<li class="page-item disabled"><a class="page-link text-center" href="#">${symbolToAdd}</a></li>`);
	} else {
		$pageNumberList.append(`<li class="page-item"><a class="page-link text-center" href="#">${symbolToAdd}</a></li>`);
	}
};

function addNextSymbol($pageNumberList, highestPageNumber, currentPageNumber, symbolToAdd) {
	if (highestPageNumber === currentPageNumber) {
		$pageNumberList.append(`<li class="page-item disabled"><a class="page-link text-center" href="#">${symbolToAdd}</a></li>`);
	} else {
		$pageNumberList.append(`<li class="page-item"><a class="page-link text-center" href="#">${symbolToAdd}</a></li>`);
	}
};

function splitPagination(currentPageNumber, highestPageNumber) {
	let $pageNumberList = $("#pagination-ul");
	let pageNumberArray = $.makeArray($("#pagination-ul li")).slice(2, ($pageNumberList.length - 3));//Remove '<<' and "<" from ends
	let pageNumbersLeft = [];
	let pageNumbersMiddle = [];
	let pageNumbersRight = [];

	for (let i = 0; i < 3; i++) {
		pageNumbersLeft.push(pageNumberArray[i]);
		pageNumbersRight.push(pageNumberArray[(highestPageNumber - 1) - i]);
	};

	pageNumbersMiddle = constructPaginationMiddle(pageNumbersMiddle, pageNumberArray, currentPageNumber, highestPageNumber)
	pageNumbersRight = pageNumbersRight.sort((a,b) => { return $(a).attr('id') - $(b).attr('id'); });

	$pageNumberList.empty();

	addPreviousSymbol($pageNumberList, currentPageNumber, beginningButtonText);
	addPreviousSymbol($pageNumberList, currentPageNumber, backButtonText);

	pageNumbersLeft.forEach((element) => { addPageNumber($pageNumberList, parseInt($(element).attr('id')), currentPageNumber); });
	$pageNumberList.append(`<li class="page-item-dots force-down-dots">&nbsp&nbsp&nbsp&nbsp...&nbsp&nbsp&nbsp&nbsp</li>`);
	pageNumbersMiddle.forEach((element) => { addPageNumber($pageNumberList, parseInt($(element).attr('id')), currentPageNumber); });
	$pageNumberList.append(`<li class="page-item-dots force-down-dots">&nbsp&nbsp&nbsp&nbsp...&nbsp&nbsp&nbsp&nbsp</li>`);
	pageNumbersRight.forEach((element) => { addPageNumber($pageNumberList, parseInt($(element).attr('id')), currentPageNumber); });

	addNextSymbol($pageNumberList, highestPageNumber, currentPageNumber, forwardButtonText);
	addNextSymbol($pageNumberList, highestPageNumber, currentPageNumber, endButtonText);
};

function constructPaginationMiddle(pageNumbersMiddle, pageNumberArray, currentPageNumber, highestPageNumber) {
	let arrayMiddle = 0;

	if (currentPageNumber >= 8) {
		arrayMiddle = (currentPageNumber <= highestPageNumber - 7) ? currentPageNumber - 1 : highestPageNumber - 7
	} else if (currentPageNumber >= 4 && currentPageNumber <= 7 ) { 
		arrayMiddle = 6; // prevents pagination from looking like: << < 1 2 3 ... 1 2 3 [4] 5 6 7 ... 11 12 13 > >>
	} else {
		arrayMiddle = (pageNumberArray.length % 2 === 0) ? (pageNumberArray.length / 2) - 1 : Math.floor(pageNumberArray.length / 2)
	}

	pageNumbersMiddle.push(pageNumberArray[arrayMiddle])

	for (let j = 1; j < 4; j++) {
		pageNumbersMiddle.push(pageNumberArray[arrayMiddle + j]);
		pageNumbersMiddle.push(pageNumberArray[arrayMiddle - j]);
	};

	return pageNumbersMiddle.sort((a,b) => { return $(a).attr('id') - $(b).attr('id'); });
};

//////////////////////////////
//// on-click downloading ////
//////////////////////////////

function downloadCursorChange() {
	$(".fa-download").hover((event) => { $(event.target).css("cursor", "pointer"); });
};