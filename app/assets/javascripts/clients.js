$(document).ready(() => {
	deleteClientPopup();
});

var deleteClientPopup = function() {
	$(".delete-client").on('submit', function(event) {
		confirm('Deleting this client will remove all of itsusers and other data. Are you sure you want to delete this client?');
	});
};