$ ->
	pUser = localStorage['pivotal_username']
	pPass = localStorage['pivotal_password']
	hUser = localStorage['harvest_username']
	hPass = localStorage['harvest_password']
	hSubdomain = localStorage['harvest_subdomain']

	$('#pivotal_username').val(pUser)
	$('#pivotal_password').val(pPass)
	$('#harvest_username').val(hUser)
	$('#harvest_password').val(hPass)
	$('#harvest_subdomain').val(hSubdomain)

	if pUser? and pPass? and hUser? and hPass? and hSubdomain?
		chrome.extension.sendMessage(method: 'login', (response) ->
			if response.error?
				for msg in response.error.messages
					$('.error').append('<div>'+msg+'</div>')
				return
			chrome.extension.sendMessage(method: 'getProjects', (response) ->
				$body = $('#projects').find('tbody')
				harvest = response.harvest
				pivotal = response.pivotal

				options = '<option value=""></option>'
				for project in pivotal
					options += '<option value="'+project.id+'">'+project.name+'</option>'

				for project in harvest
					$body.append('<tr><td><span class="code">['+project.code+']</span> '+project.name+'</td><td><select id="'+project.id+'">'+options+'</select></td></tr>')

				if localStorage['project_mapping']?
					mapping = JSON.parse(localStorage['project_mapping'])
					for map in mapping
						$('#'+map.harvest).val(map.pivotal)
			)
		)

	$('form').submit(->
		localStorage['pivotal_username'] = $('#pivotal_username').val()
		localStorage['pivotal_password'] = $('#pivotal_password').val()
		localStorage['harvest_username'] = $('#harvest_username').val()
		localStorage['harvest_password'] = $('#harvest_password').val()
		localStorage['harvest_subdomain'] = $('#harvest_subdomain').val()

		mapping = []
		for el in $('#projects select')
			$el = $(el)
			if $el.val() != ''
				mapping.push
					pivotal: $el.val()
					harvest: $el.attr('id')

		localStorage['project_mapping'] = JSON.stringify(mapping)
	)