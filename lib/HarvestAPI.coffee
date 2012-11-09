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

	getProjects: ->
		daily = @GET('daily')
		projects = []
		for project in $(daily).find('project')
			continue if $(project).children('code').text() == ''
			projects.push
				name: $(project).children('name').text()
				id: $(project).children('id').text()
				code: $(project).children('code').text()
		return projects


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
