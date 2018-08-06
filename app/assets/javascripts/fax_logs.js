// TODO Split tables into sent and received
var faxNumberOptions;
var organizationOptions;

$(document).ready(() => {
	// Will be used to rebuilds html select/options
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


var limitSelectableFaxNumbers = function() {
	$("#org-select").change(() => {
		let organizationClass = $("#org-select option:selected").attr('class');
		let $faxSelect = $("#fax-select");
		$faxSelect.empty();

		if (organizationClass === "all-org") {
			$.each(faxNumberOptions, function() {
				$faxSelect.append($(this));
			});
		} else {
			$.each(faxNumberOptions, function() { // $(this) is fax_number HTML select tag options
				if ($(this).hasClass(organizationClass) || $(this).hasClass('all-fax')) { 
					$faxSelect.append($(this)); 
				}
			});
		}
	});
};

var limitSelectableOrg = function() {
	$("#fax-select").change(() => {
		let faxNumberClass = $("#fax-select option:selected").attr('class');
		let $orgSelect = $("#org-select");
		$orgSelect.empty();

		if (faxNumberClass === "all-fax") {
			$.each(organizationOptions, function() {
				$orgSelect.append($(this));
			});
		} else {
			$.each(organizationOptions, function() { // $(this) is organization HTML select tag options
				if ($(this).hasClass(faxNumberClass) || $(this).hasClass('all-org')) {
					$orgSelect.append($(this));
					$("#org-select option").first().prop('selected', 'selected'); // possible bug this line b/c order dependent
				}
			});
		}
	});
};

var limitSelectableUser = function() {
	
}

var changeStatusColor = function() {
	// prepend a Font Awesome Icon with inline style to each <td> w/'status' class. $(this) is the entire <td> tag
	$.each($('.status'), function() {
		switch($(this).text()) {
			case 'Success':
				$(this).prepend(`
					<span style='color:limegreen'>&nbsp;<i style='font-size:10px' class="fa fa-fw fa-circle"></i>&nbsp;&nbsp;</span>
				`);
				break;
			case 'Queued':
				$(this).prepend(`
					<span style='color:darkgrey'>&nbsp;<i style='font-size:10px' class="fa fa-fw fa-circle"></i>&nbsp;&nbsp;</span>
				`)
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
				`)
				break;
			case 'Partialsuccess':
				$(this).text('Partial Success')
				$(this).prepend(`
					<span style='color:darkorange'>&nbsp;<i style='font-size:10px' class="fa fa-fw fa-circle"></i>&nbsp;&nbsp;</span>
				`)
				break;
			case 'Pendingbatch':
				$(this).text('Pending Batch');
				$(this).prepend(`
					<span style='color:darkblue'>&nbsp;<i style='font-size:10px' class="fa fa-fw fa-circle"></i>&nbsp;&nbsp;</span>
				`)
				break;
		}
	});
};
