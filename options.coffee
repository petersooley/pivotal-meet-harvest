$ ->
	$('#pivotal_username').val(localStorage['pivotal_username'])
	$('#pivotal_password').val(localStorage['pivotal_password'])
	$('#harvest_username').val(localStorage['harvest_username'])
	$('#harvest_password').val(localStorage['harvest_password'])
	$('#harvest_subdomain').val(localStorage['harvest_subdomain'])

	$('form').submit(->
		localStorage['pivotal_username'] = $('#pivotal_username').val()
		localStorage['pivotal_password'] = $('#pivotal_password').val()
		localStorage['harvest_username'] = $('#harvest_username').val()
		localStorage['harvest_password'] = $('#harvest_password').val()
		localStorage['harvest_subdomain'] = $('#harvest_subdomain').val()
	)