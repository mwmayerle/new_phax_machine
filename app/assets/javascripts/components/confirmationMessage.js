const deleteOrganizationMessage = 'Deleting this organization will permanently remove all of its users and other data. This cannot be restored. Are you sure you want to do that?';
const provisionNumberMessage = 'Purchasing this number will charge $2.00 to your account. Are you sure you want to do that?';
const userRevokeAccess = "Revoking this user's access will forbid them from logging in or sending/receiving faxes through email.Users with revoked access can be invited again at any time later.  Are you sure you want to do that?";
const userResetPassword = "This user will be unable to log in until they reset their password using this email address, however email-to-fax and fax-to-email functionality will continue. Are you sure you want to do that?";

phaxMachine.components['confirmationMessage'] = {
	render: function() {
		let page = document.getElementsByTagName("body")[0].getAttribute("data-page");

		switch (page) {
			case 'organization-index':
				let allOrgDeleteForms = document.getElementsByClassName("delete-organization");
				for (let i = 0; i < allOrgDeleteForms.length; i++) {
					new ConfirmationMessage(deleteOrganizationMessage, allOrgDeleteForms[i]);
				}
				break;
			case 'new-fax-number-fax-index':
				let purchaseButton = document.getElementById('purchase-button');
				new ConfirmationMessage(provisionNumberMessage, purchaseButton);
				break;
			case 'user-edit':
				let allRevokeAccessButtons = document.getElementsByClassName("revoke-access");
				for (let i = 0; i < allRevokeAccessButtons.length; i++) {
					new ConfirmationMessage(userRevokeAccess, allRevokeAccessButtons[i]);
				}
			case 'user-table':
				let allResetPasswordButtons = document.getElementsByClassName("reset-password");
				for (let i = 0; i < allResetPasswordButtons.length; i++) {
					new ConfirmationMessage(userResetPassword, allResetPasswordButtons[i]);
				}
				break;
		}
	}
};

class ConfirmationMessage {
	constructor(message, onClickObject) {
		this.message = message;
		this.onClickObject = onClickObject;
		this.onClickObject.addEventListener('click', this.userConfirmation.bind(this));
	};

	userConfirmation(event) {
		if (!confirm(this.message)) { event.preventDefault(); }
	};
};