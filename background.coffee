class Pivotal
	constructor: (user, pass) ->
		# Get the user's token
		self = @
		$.post('https://www.pivotaltracker.com/services/v3/tokens/active',
				username: user
				password: pass
			, (data, status) ->
				# TODO HANDLE PASSWORD/USERNAME ERRORS!!!!
				$guid = $(data).find('guid')
				self.token = $guid.text()
		)

class Harvest
	constructor: (@user, @pass, @subdomain) ->
		@POST('daily')

	POST: (path) ->
		console.log 'posting to '+'https://'+@subdomain+'.harvestapp.com/'+path
		console.log 'Basic '+Base64.encode(@user+':'+@pass)
		$.ajax(
			url: 'https://'+@subdomain+'.harvestapp.com/'+path
			type: 'GET'
			headers:
				'Content-Type': 'application/json'
				'Accept': 'application/json'
				'Authorization': 'Basic '+Base64.encode(@user+':'+@pass)
			success: (data) ->
				console.log data
			error: (xhr, text, errorThrown) ->
				console.log 'error'
				console.log text
				console.log errorThrown
		)

chrome.extension.onMessage.addListener((request, sender, sendResponse) ->
	switch request.method
		when 'login'
			pUser = localStorage['pivotal_username']
			pPass = localStorage['pivotal_password']
			hUser = localStorage['harvest_username']
			hPass = localStorage['harvest_password']
			hSubdomain = localStorage['harvest_subdomain']
			if pUser? and pPass? and hUser? and hPass?
				console.log 'logging in'
				p = new Pivotal(pUser, pPass)
				u = new Harvest(hUser, hPass, hSubdomain)
			else
				sendResponse(error: true)
		else
			sendResponse({})
)