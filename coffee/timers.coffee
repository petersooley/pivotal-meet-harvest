class Timers
	constructor: (opts) ->
		@projectId = opts.projectId
		@storyId = opts.storyId
		@$html = $(opts.html)

		if @storyId?
			@setupSingle()
		else
			@setup()

	setupSingle: ->
		timerHtml = @$html.find('#single-timer').html()
		$('.details_sidebar ul.subset li.state').after(timerHtml)
		$harvest = $('.details_sidebar ul.subset li.harvest')
		$harvest.find('select').chosen()
		$harvest.find('.toggle').click(=>
			console.log @pivotalProject
			console.log @harvestProject
		)

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

		t = new Timers(
			storyId: storyId
			projectId: projectId
			html: response
		)


	)

