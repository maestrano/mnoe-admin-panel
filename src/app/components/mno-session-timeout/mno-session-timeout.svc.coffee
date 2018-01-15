@App.service 'MnoSessionTimeout', ($q, $timeout, $uibModal, DEVISE_CONFIG) ->
  _self = @

  timer = null

  @resetTimer = ->
    _self.cancelTimer()
    console.debug 'reset timer'
    timer = $timeout(showTimeoutModal, DEVISE_CONFIG.timeout_in * 1000 - 12 * 1000)

  @cancelTimer = ->
    $timeout.cancel(timer)

  showTimeoutModal = ->
    console.debug("Timeout finished!")

    $uibModal.open({
      size: 'md'
      keyboard: false
      backdrop: 'static'
      templateUrl: 'app/components/mno-session-timeout/mno-session-timeout.html'
      controller: modalController
      })


  modalController = ($scope, $http, $interval, $uibModalInstance, MnoeCurrentUser, toastr) ->
    'ngInject'

    $scope.countdown = 10

    $interval((-> $scope.countdown -= 1), 1000, 10)

    $scope.stayLoggedIn = () ->
      $scope.isLoading = true
      MnoeCurrentUser.refreshUser().then(
        (response) ->
          $uibModalInstance.close(response)
        (error) ->
          toastr.warning("mno_enterprise.auth.sessions.timeout.error")
          $uibModalInstance.dismiss('cancel')
          $http.delete('/mnoe/auth/users/sign_out')
          $http.get('/mnoe/auth/users/sign_in')
      ).finally(-> $scope.isLoading = false)

    $scope.logOff = () ->
      $uibModalInstance.dismiss('cancel')
      $http.delete('/mnoe/auth/users/sign_out')
      $http.get('/mnoe/auth/users/sign_in')

  return @
