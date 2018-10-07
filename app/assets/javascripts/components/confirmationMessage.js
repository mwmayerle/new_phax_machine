const orgMessage = 'Deleting this organization will permanently remove all of its users and other data. This cannot be restored. Are you sure you want to do that?';
const phoneMessage = 'Purchasing this number will charge $2.00 to your account. Are you sure you want to do that?';

phaxMachine.components['confirmationMessage'] = {
	render: function() {
		let page = document.getElementsByTagName("body")[0].getAttribute("data-page");

		switch (page) {
			case 'organization-index':
				let allOrgDeleteForms = document.getElementsByClassName("delete-organization");
				for (let i = 0; i < allOrgDeleteForms.length; i++) {
					new ConfirmationMessage(orgMessage, allOrgDeleteForms[i]);
				}
				break;
			case 'new-fax-number-fax-index':
				let purchaseButton = document.getElementById('purchase-button');
				new ConfirmationMessage(phoneMessage, purchaseButton);
				break;
		}
	}
};

class ConfirmationMessage {
	constructor(message, wantedForm) {
		this.message = message;
		this.wantedForm = wantedForm;
		this.wantedForm.addEventListener('click', this.userConfirmation.bind(this));
	}

	userConfirmation(event) {
		if (!confirm(this.message)) { event.preventDefault(); };
	}
}