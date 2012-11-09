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
		data = @GET('projects', null)
		projects = []
		for project in $(data).find('project')
			name = $(project).find('name').first().text()
			id = $(project).find('id').first().text()
			projects.push
				name: name
				id: id
		return projects

	getStories: (pivotalProjectId) ->
		data = @GET('projects/'+pivotalProjectId+'/stories')
		stories = []
		for story in $(data).find('story')
			s =
				id: $(story).find('id').text()
				name: $(story).find('name').text()
			stories.push s
		return stories

	POST: (path, data) ->
		return @HTTP('POST', path, data) ->

	GET: (path, data) ->
		return @HTTP('GET', path, data)

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
		result = @GET('account/who_am_i')
		if result == false
			throw Error('There was a problem logging in to the Harvest API. See options page.')

	getAllProjects: ->
		data = @GET('projects')
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

	createEntry: (harvestProjectId, notes, hours, taskId) ->

	toggleEntry: (entryId) ->

	getEntry: (entryid) ->

	editEntry: (entryId, notes, hours, taskId) ->

	getTodaysEntriesAndTasks: (harvestProjectId) ->
		daily = @GET('daily')
		entries = []
		tasks = []

		# Find the tasks for this project
		for project in $(daily).find('project')
			id = $(project).children('id')[0]
			if id? and $(id).text() == ''+harvestProjectId
				for task in $(project).find('task')
					t =
						name: $($(task).find('name')[0]).text()
						id: $($(task).find('id')[0]).text()
						billable: $($(task).find('billable')[0]).text()
					tasks.push t
				break

		# Find any entries for this project and for today
		for entry in $(daily).find('day_entry')
			if $($(entry).find('project_id')[0]).text() == ''+harvestProjectId
				running = if $(entry).find('timer_started_at')[0]? then true else false
				e =
					id: $($(entry).find('id')[0]).text()
					hours: $($(entry).find('hours')[0]).text()
					running: running
					task: $($(entry).find('task_id')[0]).text()
					notes: $($(entry).find('notes')[0]).text()
				entries.push e
				break
		return entries: entries, tasks: tasks


	GET: (path) ->
		return @HTTP('GET', path, null)

	POST: (path, data) ->
		return @HTTP('POST', path, data)

	HTTP: (method, path, data) ->
		returnData = {}
		$.ajax(
			url: 'https://'+@subdomain+'.harvestapp.com/'+path
			type: method
			data: data
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
		@entries = []
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
	# data <-- storyId, description, taskId
	# returns whether it's running
	toggle: (data, sendResponse, error) ->
		return true
		for e in @entries
			if e.storyId == data.storyId
				entryId = e.entryId
				break
		if !entryId?
			entryId = @harvestAPI.createEntry(@harvestProjectId, data.description, 0, data.taskId)
			@entries.push entryId: entryId
		isStarted = @harvestAPI.toggleEntry(entryId)
		sendResponse(isStarted: isStarted)
		return true


	# Look for a timer for the given story
	# data <-- storyId
	# returns details about the entry (hours, whether it's running, etc.)
	get: (data, sendResponse, error) ->
		for e in @entries
			if e.storyId == data.storyId
				entry = @harvestAPI.getEntry(e.entryId)
				sendResponse(entry)
				return true

	# Edits an existing timer or creates it
	# data <-- storyId, description, hours, taskId
	edit: (data, sendResponse, error) ->
		for e in @entries
			if e.storyId == data.storyId
				entryId = e.entryId
				break
		if !entryId?
			entryId = @harvestAPI.createEntry(@harvestProjectId, data.description, data.hours, data.taskId)
			@entries.push entryId: entryId
		else
			@harvestAPI.editEntry(entryId, data.description, data.hours, data.taskId)
		sendResponse(success: true)

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
		@pivotalProjectId = data.projectId
		@harvestProjectId = false
		for map in JSON.parse(localStorage['project_mapping'])
			if map.pivotal+'' == @pivotalProjectId+''
				@harvestProjectId = map.harvest
				break
		if !@harvestProjectId
			error.messages.push "This project is not mapped to a Harvest project. See options page."
			return false

		# Create HarvestAPI thereby logging in
		if hUser? and hPass? and hSubdomain? and pUser? and pPass?
			try
				@pivotalAPI = new PivotalAPI(pUser, pPass)
			catch e
				error.messages.push e.message
			try
				@harvestAPI = new HarvestAPI(hUser, hPass, hSubdomain)
			catch e
				error.messages.push e.message

			if error.messages.length == 0
				result = @harvestAPI.getTodaysEntriesAndTasks(@harvestProjectId)

				stories = @pivotalAPI.getStories(@pivotalProjectId)
				for entry in result.entries
					for story in stories
						if entry.notes == story.name
							entry.storyId = story.id
							@entries.push entry
				sendResponse(html: @getHtml(), tasks: result.tasks)
				return true
		else
			error.messages.push "Missing login information. See options page."
		return false

	getHtml: (error) ->
		returnData = {}
		$.ajax(
			url: chrome.extension.getURL('html/timers.html')
			dataType: 'html'
			async: false
			success: (data) ->
				returnData = data
		)
		return returnData

app = new App()