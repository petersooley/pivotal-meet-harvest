class PivotalAPI
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
				throw Error('There was a problem logging in to the Pivotal Tracker API. See options page.')
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

class HarvestAPI
	constructor: (@user, @pass, @subdomain) ->
		# Run a test to be sure that logging in works.
		result = @HTTP('account/who_am_i')
		if result == false
			throw Error('There was a problem logging in to the Harvest API. See options page.')

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
		chrome.extension.onMessage.addListener((request, sender, sendResponse) =>
			error = {}
			error.messages = []
			switch request.method
				when 'login'
					return true if @login(request, sendResponse, error)
				when 'toggle'
					return true if @toggle(request, sendResponse, error)
				when 'get'
					return true if @get(request, sendResponse, error)
				when 'edit'
					return true if @edit(request, sendResponse, error)
				else
					error.messages.push "Unrecognized request method in sendMessage call."
			sendResponse(error: error)
			return true
		)

	# Create/start/stop a timer
	# data <-- storyId, description
	# returns hours and whether it started or stopped
	toggle: (data, sendResponse, error) ->


	get: (data, sendResponse, error) ->

	edit: (data, sendResponse, error) ->

	# Logs in to both HarvestAPI and PivotalAPI using settings from options page
	# data <-- projectId
	# returns the html needed for harvest timer buttons
	login: (data, sendResponse, error) ->
		pUser = localStorage['pivotal_username']
		pPass = localStorage['pivotal_password']
		hUser = localStorage['harvest_username']
		hPass = localStorage['harvest_password']
		hSubdomain = localStorage['harvest_subdomain']

		# Get the Pivotal/Harvest mapping
		@pivotalId = data.projectId
		@harvestProjectId = false
		for map in JSON.parse(localStorage['project_mapping'])
			console.log map
			if map.pivotal+'' == @pivotalId+''
				@harvestProjectId = map.harvest
				break
		if !@harvestProjectId
			error.messages.push "This project is not mapped to a Harvest project. See options page."
			return false

		# Create HarvestAPI and PivotalAPI thereby logging in
		if pUser? and pPass? and hUser? and hPass?
			try
				@pivotalAPI = new PivotalAPI(pUser, pPass)
			catch e
				error.messages.push e.message
			try
				@harvestAPI = new HarvestAPI(hUser, hPass, hSubdomain)
			catch e
				error.messages.push e.message

			if error.messages.length == 0
				# Return the html for the dynamic harvest timers
				@getHtml(sendResponse, error)
				return true
		else
			error.messages.push "Missing login information. See options page."
		return false

	getHtml: (sendResponse, error) ->
		$.ajax(
			url: chrome.extension.getURL('html/timers.html')
			dataType: 'html'
			success: sendResponse
			error: ->
				error.messages.push "Couldn't find html/timers.html"
				sendResponse(error:error)
		)
		return true

app = new App()