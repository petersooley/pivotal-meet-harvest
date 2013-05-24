// Generated by CoffeeScript 1.6.2
(function() {
  var Timers;

  Timers = (function() {
    function Timers(opts) {
      this.projectId = opts.projectId;
      this.storyId = opts.storyId;
      this.tasks = opts.tasks;
      this.$html = $(opts.html);
      if (this.storyId != null) {
        this.setupSingle();
      } else {
        this.setup();
      }
    }

    Timers.prototype.setupSingle = function() {
      var $harvest, $select, task, timerHtml, _i, _len, _ref,
        _this = this;

      timerHtml = this.$html.find('#single-timer').html();
      console.log(timerHtml);
      $('.story.info .state').after(timerHtml);
      $harvest = $('.story.info .harvest');
      console.log($harvest);
      $select = $harvest.find('select');
      _ref = this.tasks;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        task = _ref[_i];
        $select.append('<option value="' + task.id + '">' + task.name + '</option>');
      }
      $select.chosen();
      return $harvest.find('.toggle').click(function() {
        return chrome.extension.sendMessage({
          method: 'toggle',
          description: 'my test entry',
          taskId: 319532
        }, function(response) {
          return console.log(response);
        });
      });
    };

    Timers.prototype.setup = function() {
      return console.log('setting up all');
    };

    return Timers;

  })();

  window.ERR = function(msg) {
    msg = 'Pivotal Meet Harvest Error: ' + msg;
    throw new Error(msg);
  };

  $(function() {
    var projectId, storyId, uri;

    uri = document.location.pathname.split('/');
    console.log(uri);
    if (typeof uri[3] === 'undefined' || uri[2] !== 'projects') {
      return;
    }
    projectId = parseInt(uri[3]);
    storyId = null;
    if (typeof uri[3] !== 'undefined' && uri[4] === 'stories') {
      storyId = parseInt(uri[6]);
    }
    return chrome.extension.sendMessage({
      method: 'login',
      projectId: projectId
    }, function(response) {
      var t;

      if (response.error != null) {
        ERR(response.error.messages);
        return false;
      }
      return t = new Timers({
        storyId: storyId,
        projectId: projectId,
        html: response.html,
        tasks: response.tasks
      });
    });
  });

}).call(this);
