// Generated by CoffeeScript 1.3.3
(function() {

  $(function() {
    var hPass, hSubdomain, hUser, pPass, pUser;
    console.log('starting');
    pUser = localStorage['pivotal_username'];
    pPass = localStorage['pivotal_password'];
    hUser = localStorage['harvest_username'];
    hPass = localStorage['harvest_password'];
    hSubdomain = localStorage['harvest_subdomain'];
    if ((pUser != null) && (pPass != null) && (hUser != null) && (hPass != null) && (hSubdomain != null)) {
      chrome.extension.sendMessage({
        method: 'login'
      }, function(response) {
        var msg, _i, _len, _ref;
        if (response.error != null) {
          _ref = response.error.messages;
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            msg = _ref[_i];
            $('.error').append('<div>' + msg + '</div>');
          }
          return;
        }
        return chrome.extension.sendMessage({
          method: 'getProjects'
        }, function(response) {
          var $body, harvest, options, pivotal, project, _j, _k, _len1, _len2, _results;
          $body = $('#projects').find('tbody');
          harvest = response.harvest;
          pivotal = response.pivotal;
          options = '<option value=""></option>';
          for (_j = 0, _len1 = pivotal.length; _j < _len1; _j++) {
            project = pivotal[_j];
            options += '<option value="' + project.id + '">' + project.name + '</option>';
          }
          _results = [];
          for (_k = 0, _len2 = harvest.length; _k < _len2; _k++) {
            project = harvest[_k];
            _results.push($body.append('<tr><td><span class="code">[' + project.code + ']</span> ' + project.name + '</td><td><select id="' + project.id + '">' + options + '</select></td></tr>'));
          }
          return _results;
        });
      });
    }
    $('#pivotal_username').val(pUser);
    $('#pivotal_password').val(pPass);
    $('#harvest_username').val(hUser);
    $('#harvest_password').val(hPass);
    $('#harvest_subdomain').val(hSubdomain);
    return $('form').submit(function() {
      localStorage['pivotal_username'] = $('#pivotal_username').val();
      localStorage['pivotal_password'] = $('#pivotal_password').val();
      localStorage['harvest_username'] = $('#harvest_username').val();
      localStorage['harvest_password'] = $('#harvest_password').val();
      return localStorage['harvest_subdomain'] = $('#harvest_subdomain').val();
    });
  });

}).call(this);
