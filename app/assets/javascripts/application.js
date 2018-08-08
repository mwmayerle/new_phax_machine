// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, or any plugin's
// vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//

//= require jquery3
//= require jquery-ui/widgets/datepicker
//= require popper
//= require bootstrap

//= require rails-ujs
//= require activestorage
//= require bootstrap-sprockets
//= require_tree .

$(document).ready(() => {
	informationBoxMouseOver();

	// See organization.js
	deleteOrganizationPopup();

	// See faxes.js
	addUploadedFile();
	removeUploadedFile();
	dragOverColorChange();
	dragLeaveColorChange();
	adjustAttachedFileCount();

	// See users.js
	revokeUserPopup();

	// See navbar.js
	collapseSidebar();

	// See fax_logs.js
	faxSelectOnChange();
	orgSelectOnChange();
	userSelectOnChange();
	changeStatusColor();
	loadDatePicker();
});

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
}