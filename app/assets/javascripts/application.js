//= require jquery3

//= require popper
//= require bootstrap

//= require rails-ujs
//= require activestorage
//= require bootstrap-sprockets
//= require flatpickr

//= require ./_setup
//= require_tree ./pages
//= require_tree ./components

var informationBoxMouseOver = function() {
	$(".information-box").hover(function(event) {
		$(this).toggleClass('information-box-active');
	});
};

function createAlert(type, message) {
	let alert = $("<div class='alert alert-dismissable alert-" + type + "'></div>");
	let closeAlertButton = $(
		'<button type="button" class="close" data-dismiss="alert" aria-label="Close">'
		+ '<span aria-hidden="true">&times;</span>'
		+ '</button>'
	);
	alert.append(closeAlertButton);
	alert.append(message);
	$("#flash-messages").append(alert);
};