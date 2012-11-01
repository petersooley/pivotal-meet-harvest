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

window.ERR = (msg) ->
	alert(msg)
	throw new Error(msg)


$ ->

	# Get user accounts data from localStorage from background.js
	chrome.extension.sendMessage(method: 'login', (response) ->
		if response.error?
			ERR('Pivotal Meet Harvest Error: There was a problem logging in to the Pivotal Tracker API or the Harvest API. See extension options.')

		# Parse the URL to figure out the project ID and story ID
		uri = document.location.href.split('/')
		if typeof uri[4] == 'undefined' or uri[3] != 'projects'
			return
		projectId = parseInt(uri[4])
		storyId = null
		if typeof uri[5] != 'undefined' and uri[5] == 'stories'
			storyId = parseInt(uri[6])

		# Get project mappings
		chrome.extension.sendMessage(method: 'getHarvestProject', pivotalId: projectId, (harvestProject) ->

			# TODO Set up timers here
			
		)
	)

