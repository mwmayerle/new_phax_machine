phaxMachine.components['fax-log-dropdowns'] = {
	render: function() {
		const menus = getMenusFromPermission();
		menus.putAllAtSelectTagTop();
	}
};

function getMenusFromPermission() {
	switch (document.getElementById('perm').getAttribute('data-perm')) {
		case 'admin':
			return new AdminDropdown();
			break;
		case 'manager':
			return new ManagerDropdown();
			break;
		case 'user':
			return new UserDropdown();
			break;
	};
};

class FaxLogDropdown {
	constructor() {};

	emptySelectTag(tag) { tag.options.length = 0; };

	createTagOptionsObject(tag) {
		let primaryOptions = [];
		for (let i = 0; i < tag.children.length; i++) {
			primaryOptions.push({
				'optionID': tag.children[i].id,
				'optionClass': tag.children[i].className,
				'optionValue': tag.children[i].value,
				'optionText': tag.children[i].text
			});
		}
		return primaryOptions;
	};

	createOptionTag(optionTagDatum, nameObject, selectedOption = null) {
		let newOption = document.createElement('option');
		newOption.id = optionTagDatum['optionID'];
		newOption.classList.add(optionTagDatum['optionClass']);
		newOption.name = `fax_log[${nameObject}]`;
		newOption.value = optionTagDatum['optionValue'];
		newOption.text = optionTagDatum['optionText'];
		if (newOption.value === selectedOption) { newOption.selected = true };
		return newOption;
	};

	createAllLinkedOption(nameObject, nameObjectText) {
		let allLinked = document.createElement('option');
		allLinked.classList.add('all-linked');
		allLinked.name = `fax_log[${nameObject}]`;
		allLinked.value = 'all-linked';
		allLinked.text = nameObjectText;
		allLinked.selected = true;
		return allLinked;
	};

	rebuildSelectTag(selectTag, selectTagOptions, selectObject, selectedValue) {
		let addLast = '';
		selectTagOptions.forEach(optionTagDatum => {
			if (optionTagDatum['optionText'] !== 'All') {
				selectTag.appendChild(this.createOptionTag(optionTagDatum, selectObject, selectedValue));
			} else {
				addLast = this.createOptionTag(optionTagDatum, selectObject, selectedValue);
			}
		});
		selectTag.insertBefore(addLast, selectTag.children[0]);
	};

	putAllAtSelectTagTop() {
		this.emptySelectTag(this.primarySelect);
		this.rebuildSelectTag(this.primarySelect, this.primarySelectOptions, this.primarySelectObjectName, 'all');
		if (this.secondarySelectOptions) {
			this.emptySelectTag(this.secondarySelect);
			this.rebuildSelectTag(this.secondarySelect, this.secondarySelectOptions, this.secondarySelectObjectName, 'all');
		}
	};
};

class AdminDropdown extends FaxLogDropdown {
	constructor() {
		super();
		this.primaryAllClass = 'all-org';
		this.primarySelect = document.getElementById('org-select');
		this.primarySelectOptions = this.createTagOptionsObject(this.primarySelect);
		this.primarySelectObjectName = 'organization';
		this.primarySelect.addEventListener('click', this.primarySelectTagClickHandlerAdmin.bind(this));
		this.secondaryAllClass = 'all-fax';
		this.secondarySelect = document.getElementById('fax-select');
		this.secondarySelectOptions = this.createTagOptionsObject(this.secondarySelect);
		this.secondarySelectObjectName = 'fax_number';
		this.secondarySelect.addEventListener('click', this.secondarySelectTagClickHandlerAdmin.bind(this));
		this.allLinkedText = 'All Linked Numbers';
	};

	primarySelectTagClickHandlerAdmin() {
		let selectedValue = this.primarySelect.value;
		this.emptySelectTag(this.secondarySelect);

		if (selectedValue === 'all') {
			this.emptySelectTag(this.primarySelect);
			this.rebuildSelectTag(this.primarySelect, this.primarySelectOptions, this.primarySelectObjectName, selectedValue);
			this.rebuildSelectTag(this.secondarySelect, this.secondarySelectOptions, this.secondarySelectObjectName, selectedValue);
		} else {
			this.secondarySelect.prepend(this.createAllLinkedOption(this.secondarySelectObjectName, this.allLinkedText));
			let filteredSecondarySelectOptions = this.secondarySelectOptions.filter(optionTagDatum => {
				return parseInt(optionTagDatum['optionClass']) === parseInt(this.primarySelect[this.primarySelect.selectedIndex].className) || optionTagDatum['optionClass'] === this.secondaryAllClass;
			});
			this.rebuildSelectTag(this.secondarySelect, filteredSecondarySelectOptions, this.secondarySelectObjectName, selectedValue);
		}
	};
	
	secondarySelectTagClickHandlerAdmin() {
		let selectedClass = this.secondarySelect[this.secondarySelect.selectedIndex].className;
		let selectedValue = this.secondarySelect.value;
		
		switch (selectedValue) {
			case 'all':
				this.emptySelectTag(this.primarySelect);
				this.emptySelectTag(this.secondarySelect);
				this.rebuildSelectTag(this.primarySelect, this.primarySelectOptions, this.primarySelectObjectName, selectedValue);
				this.rebuildSelectTag(this.secondarySelect, this.secondarySelectOptions, this.secondarySelectObjectName, selectedValue);
				break;
			case 'all-linked':
				break; // Do nothing
			default:
				this.emptySelectTag(this.primarySelect);
				let selectTagOptions = this.primarySelectOptions.filter(optionTagDatum => { 
					return parseInt(optionTagDatum['optionClass']) === parseInt(selectedClass) || optionTagDatum['optionClass'] === this.primaryAllClass;
				});
				this.rebuildSelectTag(this.primarySelect, selectTagOptions, this.primarySelectObjectName, selectedValue);
				break;
		}
	}
};

class ManagerDropdown extends FaxLogDropdown {
	//select a number (primary), users should have the users and "all-linked"
	constructor() {
		super();
		this.primaryAllClass = 'all-fax';
		this.primarySelect = document.getElementById('fax-select');
		this.primarySelectOptions = this.createTagOptionsObject(this.primarySelect);
		this.primarySelectObjectName = 'fax_number';
		this.primarySelect.addEventListener('click', this.primarySelectTagClickHandlerManager.bind(this));
		this.secondaryAllClass = 'all-user';
		this.secondarySelect = document.getElementById('user-select');
		this.secondarySelectOptions = this.createTagOptionsObject(this.secondarySelect);
		this.secondarySelectObjectName = 'user';
		this.secondarySelect.addEventListener('click', this.secondarySelectTagClickHandlerManager.bind(this));
		this.allLinkedPrimaryText = 'All Linked Numbers';
		this.allLinkedSecondaryText = 'All Linked Users';
	};

	primarySelectTagClickHandlerManager() {
		let selectedClass = this.primarySelect[this.primarySelect.selectedIndex].className;
		let selectedValue = this.primarySelect.value;
		
		switch (selectedClass) {
			case this.primaryAllClass:
				this.emptySelectTag(this.primarySelect);
				this.emptySelectTag(this.secondarySelect);
				this.rebuildSelectTag(this.primarySelect, this.primarySelectOptions, this.primarySelectObjectName, selectedValue);
				this.rebuildSelectTag(this.secondarySelect, this.secondarySelectOptions, this.secondarySelectObjectName, selectedValue);
				break;
			case 'all-linked':
				break;
			default:
				let selectedSecondaryClass = this.secondarySelect[this.secondarySelect.selectedIndex].className;
				if (parseInt(selectedSecondaryClass) !== NaN) {
					this.emptySelectTag(this.secondarySelect);
					this.secondarySelect.prepend(this.createAllLinkedOption(this.secondarySelectObjectName, this.allLinkedSecondaryText));
					this.rebuildSelectTag(this.secondarySelect, this.secondarySelectOptions, this.secondarySelectObjectName, selectedValue);
				}
				break;
		}
	};

	secondarySelectTagClickHandlerManager() {
		let selectedClass = this.secondarySelect[this.secondarySelect.selectedIndex].className;
		let selectedValue = this.secondarySelect.value;
		switch (selectedClass) {
			case this.secondaryAllClass:
				this.emptySelectTag(this.primarySelect);
				this.emptySelectTag(this.secondarySelect);
				this.rebuildSelectTag(this.primarySelect, this.primarySelectOptions, this.primarySelectObjectName, selectedValue);
				this.rebuildSelectTag(this.secondarySelect, this.secondarySelectOptions, this.secondarySelectObjectName, selectedValue);
				break;
			case 'all-linked':
				break;
			default:
				let selectedPrimaryClass = this.primarySelect[this.primarySelect.selectedIndex].className;
				if (parseInt(selectedPrimaryClass) === NaN) {
					this.emptySelectTag(this.primarySelect);
					this.primarySelect.prepend(this.createAllLinkedOption(this.primarySelectObjectName, this.allLinkedPrimaryText));
					this.rebuildSelectTag(this.primarySelect, this.primarySelectOptions, this.primarySelectObjectName, selectedValue);
				}
				break;
		}
	};
}

class UserDropdown extends FaxLogDropdown {
	constructor() {
		super();
		this.primarySelect = document.getElementById('fax-select');
		this.primarySelectOptions = this.createTagOptionsObject(this.primarySelect);
		this.primarySelectObjectName = 'fax_number';
	};
};