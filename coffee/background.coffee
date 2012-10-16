class Pivotal
	constructor: (user, pass) ->
		@url = 'https://www.pivotaltracker.com/services/v3/'
		# Get the user's token
		self = @
		$.ajax(
			url: @url+'tokens/active'
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

	getAllProjects: ->
		data = @HTTP('GET','projects', null)
		projects = []
		for project in $(data).find('project')
			name = $(project).find('name').first().text()
			id = $(project).find('id').first().text()
			projects.push
				name: name
				id: id
		return projects

	HTTP: (method, path, data) ->
		returnData = false
		$.ajax(
			url: @url+path
			type: method
			async: false
			data: data
			headers:
				'X-TrackerToken': @token
			success: (data) ->
				returnData = data
			error: ->
				returnData = false
		)
		return returnData

class Harvest
	constructor: (@user, @pass, @subdomain) ->
		# Run a test to be sure that logging in works.
		result = @HTTP('account/who_am_i')
		if result == false
			throw Error('Harvest login failure.')

	getAllProjects: ->
		data = @HTTP('projects')
		projects = []
		for project in $(data).find('project')
			name = $(project).find('name').text()
			id = $(project).find('id').text()
			code = $(project).find('code').text()
			projects.push
				name: name
				id: id
				code: code
		return projects


	HTTP: (path) ->
		returnData = {}
		$.ajax(
			url: 'https://'+@subdomain+'.harvestapp.com/'+path
			type: 'GET'
			async: false
			headers:
				'Content-Type': 'application/xml'
				'Accept': 'application/xml'
				'Authorization': 'Basic '+Base64.encode(@user+':'+@pass)
			success: (data, status) ->
				returnData = data
			error: (xhr, status, error) ->
				returnData = false
		)
		return returnData

class App
	constructor: ->
		@pivotal = {}
		@harvest = {}

		chrome.extension.onMessage.addListener((request, sender, sendResponse) =>
			error = {}
			error.messages = []
			switch request.method
				when 'login'
					return true if @login(sendResponse, error)
				when 'getProjects'
					return true if @getProjects(sendResponse, error)
				else
					error.messages = [
						"Unrecognized request method in sendMessage call."
					]
			sendResponse(error: error)
			return true
		)

	login: (sendResponse, error) ->
		pUser = localStorage['pivotal_username']
		pPass = localStorage['pivotal_password']
		hUser = localStorage['harvest_username']
		hPass = localStorage['harvest_password']
		hSubdomain = localStorage['harvest_subdomain']
		pivotalError = null
		harvestError = null
		if pUser? and pPass? and hUser? and hPass?
			try
				@pivotal = new Pivotal(pUser, pPass)
			catch e
				error.messages.push e.message
			try
				@harvest = new Harvest(hUser, hPass, hSubdomain)
			catch e
				error.messages.push e.message

			if error.messages.length == 0
				sendResponse(success: true)
				return true
		else
			error.messages = [
				"Missing login information. See options page."
			]
		return false

	getProjects: (sendResponse, error) ->
		pivotalProjects = @pivotal.getAllProjects()
		harvestProjects = @harvest.getAllProjects()
		sendResponse(
			pivotal: pivotalProjects
			harvest: harvestProjects
		)
		return true

app = new App()