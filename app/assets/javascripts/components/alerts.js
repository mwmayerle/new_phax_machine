class MessageAlert {
	constructor(alertType, alertText) {
		this.alertLocation = document.getElementById("flash-messages");
		this.alertType = alertType;
		this.alertText = alertText;
	}

	createAlert() {
		let alert = document.createElement("div");
		let classes = ['alert', 'alert-dismissable', `alert-${this.alertType}`];
		classes.forEach(newClass => alert.classList.add(newClass));
		alert.innerHTML = `<button type="button" class="close" data-dismiss="alert" aria-label="Close"><span aria-hidden="true">&times;</span></button>${this.alertText}`;
		this.alertLocation.appendChild(alert);
	}
}

phaxMachine.components['alerts'] = {
	render: function() {}
};