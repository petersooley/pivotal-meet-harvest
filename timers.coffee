class Timers
	constructor: (opts) ->
		@projectId = opts.projectId
		@storyId = opts.storyId
		@pivotalToken = opts.pivotalToken

		if @storyId?
			@setupSingle()
		else
			@setup()

	setupSingle: ->
		console.log 'setting up single'

	setup: ->
		console.log 'setting up all'


$ ->
	# Get user accounts data from localStorage from background.js
	chrome.extension.sendMessage(method: 'login', (response) ->
		console.log 'got response'

		if response.error?
			msg = 'Pivotal Meet Harvest Error: There was a problem logging in to the Pivotal Tracker API or the Harvest API. See extension options.'
			alert(msg)
			throw new Error(msg)

		# Parse the URL to figure out the project ID and story ID
		uri = document.location.href.split('/')
		if typeof uri[4] == 'undefined' or uri[3] != 'projects'
			return
		projectId = parseInt(uri[4])
		storyId = null
		if typeof uri[5] != 'undefined' and uri[5] == 'stories'
			storyId = parseInt(uri[6])
	)