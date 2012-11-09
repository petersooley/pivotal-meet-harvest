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

	getProjects: ->
		data = @GET('projects', null)
		projects = []
		for project in $(data).find('project')
			name = $(project).find('name').first().text()
			id = $(project).find('id').first().text()
			projects.push
				name: name
				id: id
		return projects

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