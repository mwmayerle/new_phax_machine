window.phaxMachine = {}
phaxMachine.pages = {}
phaxMachine.$body = $('body')
phaxMachine.$window = $(window)

$(document).ready(() => {
	phaxMachine.page = $('body').data('page');

	if (phaxMachine.page in phaxMachine.pages) {
 		var page = phaxMachine.pages[phaxMachine.page];
		if (page.render) { page.render(); }
	}
});