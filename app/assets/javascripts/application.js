//= require jquery3

//= require popper
//= require bootstrap

//= require rails-ujs
//= require activestorage
//= require bootstrap-sprockets
//= require flatpickr

//= require ./_setup
//= require_tree ./pages
//= require_tree ./components

var informationBoxMouseOver = function() {
	$(".information-box").hover(function(event) {
		$(this).toggleClass('information-box-active');
	});
};