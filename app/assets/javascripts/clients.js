$(document).ready(() => {
	deleteClientPopup();
});

var deleteClientPopup = function() {
	$(".delete-client").on('submit', function(event) {
		let result = confirm('Deleting this client will permanently remove all of its users and other data. Are you sure you want to delete this client?');
		if (result) {
			return true;
		} else {
			event.stopImmediatePropagation();
			return false;
		}
	});
};