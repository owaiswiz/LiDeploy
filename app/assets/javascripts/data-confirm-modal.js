//data-confirm-modal
(function ($) {
  var defaults = {
    title: 'Are you sure?',
    commit: 'Confirm',
    commitClass: 'btn-primary destroy',
    cancel: 'Cancel',
    cancelClass: 'btn-default',
    fade: true,
    verifyClass: 'form-control',
    elements: ['a[data-confirm]', 'button[data-confirm]', 'input[type=submit][data-confirm]'],
    focus: 'commit',
    zIndex: 1050,
    modalClass: false,
    show: true
  };
  var settings;
  window.dataConfirmModal = {
    setDefaults: function (newSettings) {
      settings = $.extend(settings, newSettings);
    },
    restoreDefaults: function () {
      settings = $.extend({}, defaults);
    },
    confirm: function (options) {
      var modal = buildModal(options);
      modal.spawn();
      modal.on('hidden.bs.modal', function () {
        modal.remove();
      });
      modal.find('.commit').on('click', function () {
        if (options.onConfirm && options.onConfirm.call)
          options.onConfirm.call();
        modal.modal('hide');
      });
      modal.find('.cancel').on('click', function () {
        if (options.onCancel && options.onCancel.call)
          options.onCancel.call();
        modal.modal('hide');
      });
    }
  };
  dataConfirmModal.restoreDefaults();
  var buildElementModal = function (element) {
    var options = {
      title:        element.attr('title') || element.data('original-title'),
      text:         element.data('confirm'),
      focus:        element.data('focus'),
      method:       element.data('method'),
      commit:       element.data('commit'),
      commitClass:  element.data('commit-class'),
      cancel:       element.data('cancel'),
      cancelClass:  element.data('cancel-class'),
      remote:       element.data('remote'),
      verify:       element.data('verify'),
      verifyRegexp: element.data('verify-regexp'),
      verifyLabel:  element.data('verify-text'),
      verifyRegexpCaseInsensitive: element.data('verify-regexp-caseinsensitive'),
      backdrop:     element.data('backdrop'),
      keyboard:     element.data('keyboard'),
      show:         element.data('show')
    };
    var modal = buildModal(options);
    modal.data('confirmed', false);
    modal.find('.commit').on('click', function () {
      modal.data('confirmed', true);
      element.trigger('click');
      modal.modal('hide');
    })
    return modal;
  }
  var buildModal = function (options) {
    var id = 'confirm-modal-' + String(Math.random()).slice(2, -1);
    var fade = settings.fade ? 'fade' : '';
    var modalClass = settings.modalClass ? settings.modalClass : '';
    var modal = $(
      '<div id="'+id+'" class="modal '+fade+' '+modalClass+'" tabindex="-1" role="dialog" aria-labelledby="'+id+'Label" aria-hidden="true">' +
        '<div class="modal-dialog">' +
          '<div class="modal-content">' +
            '<div class="modal-header">' +
              '<button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>' +
              '<h4 id="'+id+'Label" class="modal-title"></h4> ' +
            '</div>' +
            '<div class="modal-body"></div>' +
            '<div class="modal-footer">' +
              '<button class="btn cancel" data-dismiss="modal" aria-hidden="true"></button>' +
              '<button class="btn commit"></button>' +
            '</div>'+
          '</div>'+
        '</div>'+
      '</div>'
    );
    var highest = current = settings.zIndex;
    $('.modal.in').not('#'+id).each(function() {
      current = parseInt($(this).css('z-index'), 10);
      if(current > highest) {
        highest = current
      }
    });
    modal.css('z-index', parseInt(highest) + 1);
    modal.find('.modal-title').text(options.title || settings.title);
    var body = modal.find('.modal-body');
    $.each((options.text||'').split(/\n{2}/), function (i, piece) {
      body.append($('<p/>').html(piece));
    });
    var commit = modal.find('.commit');
    commit.text(options.commit || settings.commit);
    commit.addClass(options.commitClass || settings.commitClass);
    var cancel = modal.find('.cancel');
    cancel.text(options.cancel || settings.cancel);
    cancel.addClass(options.cancelClass || settings.cancelClass);
    if (options.remote) {
      commit.attr('data-dismiss', 'modal');
    }
    if (options.verify || options.verifyRegexp) {
      commit.prop('disabled', true);
      var isMatch;
      if (options.verifyRegexp) {
        var caseInsensitive = options.verifyRegexpCaseInsensitive;
        var regexp = options.verifyRegexp;
        var re = new RegExp(regexp, caseInsensitive ? 'i' : '');
        isMatch = function (input) { return input.match(re) };
      } else {
        isMatch = function (input) { return options.verify == input };
      }
      var verification = $('<input/>', {"type": 'text', "class": settings.verifyClass}).on('keyup', function () {
        commit.prop('disabled', !isMatch($(this).val()));
      });
      modal.on('shown.bs.modal', function () {
        verification.focus();
      });
      modal.on('hidden.bs.modal', function () {
        verification.val('').trigger('keyup');
      });
      if (options.verifyLabel)
        body.append($('<p>', {text: options.verifyLabel}))

      body.append(verification);
    }
    var focus_element;
    if (options.focus) {
      focus_element = options.focus;
    } else if (options.method == 'delete') {
      focus_element = 'cancel'
    } else {
      focus_element = settings.focus;
    }
    focus_element = modal.find('.' + focus_element);
    modal.on('shown.bs.modal', function () {
      focus_element.focus();
    });
    $('body').append(modal);
    modal.spawn = function() {
      return modal.modal({
        backdrop: options.backdrop,
        keyboard: options.keyboard,
        show:     options.show
      });
    };

    return modal;
  };
  var getModal = function (element) {
    var modal = element.data('confirm-modal') || buildElementModal(element);

    if (modal && !element.data('confirm-modal'))
      element.data('confirm-modal', modal);

    return modal;
  };
  $.fn.confirmModal = function () {
    getModal($(this)).spawn();

    return this;
  };
  if ($.rails) {
    $(document).delegate(settings.elements.join(', '), 'confirm', function() {
      var element = $(this), modal = getModal(element);
      var confirmed = modal.data('confirmed');

      if (!confirmed && !modal.is(':visible')) {
        modal.spawn();

        var confirm = $.rails.confirm;
        $.rails.confirm = function () { return modal.data('confirmed'); }
        modal.on('hide', function () { $.rails.confirm = confirm; });
      }

      return confirmed;
    });
  }
})(jQuery);