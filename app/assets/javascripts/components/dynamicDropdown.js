phaxMachine.components['purchaseFaxNumberDropdown'] = {
	render: function() {
		let dropDownMenu = new PurchaseFaxNumberDropdown();
	}
};

class PurchaseFaxNumberDropdown {
	constructor() {
		this.areaCodeSelectTag = document.getElementById("area-codes");
		this.areaCodeOptionTagObject = this.createSelectTagObject();
		this.stateSelectTag = document.getElementById("states");
		this.stateSelectTag.addEventListener("change", () => this.rebuildDropDownMenu() );
	};

	createSelectTagObject() {
		let areaCodeOptionTagObject = {};
		for (let i = 0; i < this.areaCodeSelectTag.length; i++) {
			areaCodeOptionTagObject[this.areaCodeSelectTag[i].value] = {
				'text': this.areaCodeSelectTag[i].text,
				'state': this.areaCodeSelectTag[i].id
			}
		}
		return areaCodeOptionTagObject;
	};

	rebuildDropDownMenu() {
		this.areaCodeSelectTag.options.length = 0; //Remove all options

		Object.keys(this.areaCodeOptionTagObject).forEach(areaCode => {
			if (document.getElementById("states").value === 'all') { //Add options based on criteria
				this.createOptionTag(this.areaCodeOptionTagObject, areaCode);
			} else {
				if (this.areaCodeOptionTagObject[areaCode]['state'] === document.getElementById("states").value) {
					this.createOptionTag(this.areaCodeOptionTagObject, areaCode);
				}
			}
		});
	};

	createOptionTag(areaCodeOptionTagObject, areaCode) {
		let optionTag = document.createElement('option');
		optionTag.name = 'fax_number[area_code]';
		optionTag.text = areaCodeOptionTagObject[areaCode]['text'];
		optionTag.id = areaCodeOptionTagObject[areaCode]['state'];
		optionTag.value = areaCode;
		optionTag.classList.add('form-group');
		this.areaCodeSelectTag.add(optionTag);
	};
}
