var revokeUserPopup = function() {
	$(".revoke-access").on('click', function(event) {
		let result = confirm("Revoking this user's access will forbid them from logging in or sending/receiving faxes through email.Users with revoked access can be invited again at any time later.  Are you sure you want to do that?");
		if (result) {
			return true;
		} else {
			event.stopImmediatePropagation();
			return false;
		}
	});
};