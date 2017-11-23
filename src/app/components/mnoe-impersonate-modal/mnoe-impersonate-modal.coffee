@App.component('mnoeImpersonateModal', {
  templateUrl: 'app/components/mnoe-impersonate-modal/mnoe-impersonate-modal.html',
  bindings: {
    resolve: '<'
    close: '&'
    dismiss: '&'
  }
  controller: () ->
    ctrl = this

    ctrl.cancel = () ->
      ctrl.dismiss({$value: "cancel"})

    ctrl.ok = () ->
      # Launch Cb
      ctrl.resolve.actionCb()
      ctrl.close()
    return
  })
