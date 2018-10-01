phaxMachine.pages['new-fax-number-fax-index'] = {

	render: function() {
		$("#purchase-button").on('click', $("#clickable-dropdown"), function(event) {
			let result = confirm('Purchasing this number will charge $2.00 to your account. Are you sure you want to do that?');
			if (result) {
				return true;
			} else {
				event.stopImmediatePropagation();
				return false;
			}
		});

		originalAreaCodeOptions = $("#area-codes option")
		$("#states").change(function(event) {
			$("#area-codes").empty();
			if ($("#states").val() === "all") {
				$.each(originalAreaCodeOptions, function(option) {
					$("#area-codes").append($(this));
				});
			} else {
				for (let i = 0; i < originalAreaCodeOptions.length; i++) {
					let $areaCodeOption = $(originalAreaCodeOptions[i]);
					if ($areaCodeOption.attr('id') === $("#states").val()) {
						let $val = $areaCodeOption.val();
						let $text = $areaCodeOption.text();
						let $id = $areaCodeOption.attr('id');
						$("#area-codes").append($(`
							<option id='${$id}' class='form-group' name='fax_number[area_code]' value='${$val}'>
								${$text}
							</option>
						`));
					}
				}
			}
		});

	}
};