$ ->
	console.log 'starting'
	pUser = localStorage['pivotal_username']
	pPass = localStorage['pivotal_password']
	hUser = localStorage['harvest_username']
	hPass = localStorage['harvest_password']
	hSubdomain = localStorage['harvest_subdomain']

	if pUser? and pPass? and hUser? and hPass? and hSubdomain?
		console.log 'checking response'
		chrome.extension.sendMessage(method: 'login', (response) ->
			console.log response
			if response.error?
				console.log 'error'
		)

	$('#pivotal_username').val(pUser)
	$('#pivotal_password').val(pPass)
	$('#harvest_username').val(hUser)
	$('#harvest_password').val(hPass)
	$('#harvest_subdomain').val(hSubdomain)

	$('form').submit(->
		localStorage['pivotal_username'] = $('#pivotal_username').val()
		localStorage['pivotal_password'] = $('#pivotal_password').val()
		localStorage['harvest_username'] = $('#harvest_username').val()
		localStorage['harvest_password'] = $('#harvest_password').val()
		localStorage['harvest_subdomain'] = $('#harvest_subdomain').val()
	)