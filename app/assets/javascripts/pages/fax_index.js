phaxMachine.pages['fax-index'] = {

	render: function() {
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