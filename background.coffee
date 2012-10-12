class Pivotal
	constructor: (user, pass) ->
		# Get the user's token
		self = @
		$.ajax(
			url: 'https://www.pivotaltracker.com/services/v3/tokens/active'
			type: 'POST'
			async: false
			data:
				username: user
				password: pass
			success: (data) ->
				$guid = $(data).find('guid')
				self.token = $guid.text()
			error: (xhr, status, error) ->
				throw Error('Pivotal Tracker login failure.')
		)

class Harvest
	constructor: (@user, @pass, @subdomain) ->
		# Run a test to be sure that logging in works.
		@POST('account/who_am_i')

	POST: (path) ->
		returnData = {}
		$.ajax(
			url: 'https://'+@subdomain+'.harvestapp.com/'+path
			type: 'GET'
			async: false
			headers:
				'Content-Type': 'application/json'
				'Accept': 'application/json'
				'Authorization': 'Basic '+Base64.encode(@user+':'+@pass)
			success: (data, status) ->
				returnData = data
			error: (xhr, status, error) ->
				throw Error('Harvest login failure.')
		)
		return returnData

# START HERE

pivotal = {}
harvest = {}

chrome.extension.onMessage.addListener((request, sender, sendResponse) ->
	error = {}
	error.messages = []
	switch request.method
		when 'login'
			pUser = localStorage['pivotal_username']
			pPass = localStorage['pivotal_password']
			hUser = localStorage['harvest_username']
			hPass = localStorage['harvest_password']
			hSubdomain = localStorage['harvest_subdomain']
			pivotalError = null
			harvestError = null
			if pUser? and pPass? and hUser? and hPass?
				console.log 'logging in'
				try
					pivotal = new Pivotal(pUser, pPass)
				catch e
					console.log e
					error.messages.push e.message
				try
					harvest = new Harvest(hUser, hPass, hSubdomain)
				catch e
					error.messages.push e.message

				if error.messages.length == 0
					sendResponse(success: true)
					return
			else
				error.messages = [
					"Missing login information. See options page."
				]
		else
			error.messages = [
				"Missing request method in sendMessage call."
			]

	sendResponse(error: error)
)