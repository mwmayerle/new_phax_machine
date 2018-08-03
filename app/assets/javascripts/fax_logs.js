var loadDatePicker = function() {
	$('.datepicker-inline').datepicker({
    dateFormat: 'mm-dd-yy',
    endDate: '+0d',
    autoclose: true,
    maxDate: (0),
  });
	$('#end-date-field').val(getTodaysFormattedDate());
}

function getTodaysFormattedDate() {
	let today = new Date();
	let dd = today.getDate();
	let mm = today.getMonth() + 1; // January is 0
	let yyyy = today.getFullYear();

	if (dd<10) { dd = `0${dd}` } 
	if (mm<10) { mm = `0${mm}` } 

	return `${mm}-${dd}-${yyyy}`;
}