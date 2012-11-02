class Timers
	constructor: (opts) ->
		console.log opts
		@pivotalProject = opts.pivotalProject
		@harvestProject = opts.harvestProject
		@storyId = opts.storyId

		if @storyId?
			@setupSingle()
		else
			@setup()

	setupSingle: ->
		console.log 'setting up single'

	setup: ->
		console.log 'setting up all'

window.ERR = (msg) ->
	msg = 'Pivotal Meet Harvest Error: '+msg
#	alert(msg)
	throw new Error(msg)


$ ->

	# Get user accounts data from localStorage from background.js
	chrome.extension.sendMessage(method: 'login', (response) ->
		if response.error?
			ERR('There was a problem logging in to the Pivotal Tracker API or the Harvest API. See extension options.')

		# Parse the URL to figure out the project ID and story ID
		uri = document.location.href.split('/')
		if typeof uri[4] == 'undefined' or uri[3] != 'projects'
			return
		projectId = parseInt(uri[4])
		storyId = null
		if typeof uri[5] != 'undefined' and uri[5] == 'stories'
			storyId = parseInt(uri[6])

		# Get project mappings
		chrome.extension.sendMessage(method: 'getProjectPair', pivotalId: projectId, (response) ->
			if response.error?
				ERR('This project is not mapped to any project in Harvest. See extension options.')
				return

			t = new Timers(
				harvestProject: response.harvestProject,
				storyId: storyId,
				pivotalProject: response.pivotalProject
			)

		)
	)

