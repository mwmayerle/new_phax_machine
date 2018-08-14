phaxMachine.pages['organization-index'] = {
	render: function() {
		$(".delete-organization").on('submit', function(event) {
			let result = confirm('Deleting this organization will permanently remove all of its users and other data. Are you sure you want to do that?');
			if (result) {
				return true;
			} else {
				event.stopImmediatePropagation();
				return false;
			}
		});
	}
}