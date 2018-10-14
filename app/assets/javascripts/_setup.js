window.phaxMachine = {}
phaxMachine.pages = {}
phaxMachine.components = {};
phaxMachine.$body = $('body')
phaxMachine.$window = $(window)

$(document).ready(() => {
	phaxMachine.page = $('body').data('page');
	phaxMachine.pageComponents = $('body').data('components');

	if (phaxMachine.page in phaxMachine.pages) {
 		var page = phaxMachine.pages[phaxMachine.page];
		if (page.render) { page.render(); }
	}

	if (phaxMachine.pageComponents !== undefined) {
		phaxMachine.pageComponents.split(' ').forEach(pageComponent => {
			if (pageComponent in phaxMachine.components) {
				var component = phaxMachine.components[pageComponent]
				if (component.render) { component.render(); }
			}
		})
	}
});