function loadCalendar() {
	let calendar = document.getElementsByClassName('datepicker-inline');
	calendar.flatpickr({
  	enableTime: true,
  	dateFormat: 'Y-m-d h:iK',
  	altInput: true,
  	altFormat: 'm-d-Y h:i K',
    maxDate: new Date(),
    autoclose: true,
	});
	return calendar;
};

phaxMachine.components['calendar'] = {
	render: function() {
		loadCalendar();
	}
};

