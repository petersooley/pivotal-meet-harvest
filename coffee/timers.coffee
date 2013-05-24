class Timers
	constructor: (opts) ->
		@projectId = opts.projectId
		@storyId = opts.storyId
		@tasks = opts.tasks
		@$html = $(opts.html)

		if @storyId?
			@setupSingle()
		else
			@setup()

	setupSingle: ->
		timerHtml = @$html.find('#single-timer').html()
		$('.story.info .state').after(timerHtml)
		$harvest = $('.story.info .harvest')
		$select = $harvest.find('select')
		for task in @tasks
			$select.append('<option value="'+task.id+'">'+task.name+'</option>')
		$select.chosen()
		$harvest.find('.toggle').click(=>
			chrome.extension.sendMessage(method: 'toggle',	description: 'my test entry', taskId: 319532, (response) ->
				console.log response
			)
		)

	setup: ->
		console.log 'setting up all'

window.ERR = (msg) ->
	msg = 'Pivotal Meet Harvest Error: '+msg
#	alert(msg)
	throw new Error(msg)


$ ->

	# Parse the URL to figure out the project ID and story ID
	uri = document.location.pathname.split('/')
	if typeof uri[3] == 'undefined' or uri[2] != 'projects'
		return
	projectId = parseInt(uri[3])
	storyId = null
	if typeof uri[3] != 'undefined' and uri[4] == 'stories'
		storyId = parseInt(uri[6])

	# Get user accounts data from localStorage from background.js
	chrome.extension.sendMessage(method: 'login', projectId: projectId, (response) ->
		if response.error?
			ERR(response.error.messages)
			return false

		t = new Timers(
			storyId: storyId
			projectId: projectId
			html: response.html
			tasks: response.tasks
		)


	)

