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
				when 'downloadProjects'
					return true if @downloadProjects(sendResponse, error)
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

		# Login and get info
		if @loginToAPIs(error)
			result = @harvestAPI.getTodaysEntriesAndTasks(@harvestProjectId)
			stories = @pivotalAPI.getStories(@pivotalProjectId)
			for entry in result.entries
				for story in stories
					if entry.notes == story.name
						entry.storyId = story.id
						@entries.push entry
			sendResponse(html: @getHtml(), tasks: result.tasks)
			return true
		return false

	downloadProjects: (sendResponse, error) ->
		return false if !@loginToAPIs(error)
		pivotalProjects = @pivotalAPI.getProjects()
		harvestProjects = @harvestAPI.getProjects()
		sendResponse(
			pivotal: pivotalProjects
			harvest: harvestProjects
		)
		return true

	loginToAPIs: (error) ->
		pUser = localStorage['pivotal_username']
		pPass = localStorage['pivotal_password']
		hUser = localStorage['harvest_username']
		hPass = localStorage['harvest_password']
		hSubdomain = localStorage['harvest_subdomain']

		if hUser? and hPass? and hSubdomain? and pUser? and pPass?
			try
				@pivotalAPI = new PivotalAPI(pUser, pPass)
			catch e
				error.messages.push e.message
			try
				@harvestAPI = new HarvestAPI(hUser, hPass, hSubdomain)
			catch e
				error.messages.push e.message

			if error.messages.length != 0
				error.messages.push "Missing login information. See options page."
				return false
			return true
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