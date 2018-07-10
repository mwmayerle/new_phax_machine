$(document).ready(function () {
	collapseSidebar();
});

var collapseSidebar = function() {
	$('#sidebarCollapse').on('click', function () {
    $('#sidebar').toggleClass('active');
  });
}