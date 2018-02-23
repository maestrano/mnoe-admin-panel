@App.service 'MnoSessionTimeout', ($q, $window, $timeout, $uibModal, DEVISE_CONFIG) ->
  _self = @

  timer = null
  countdownInterval = null

  @resetTimer = ->
    _self.cancelTimer()
    timer = $timeout(showTimeoutModal, (DEVISE_CONFIG.timeout_in - 12) * 1000)

  @cancelTimer = ->
    $timeout.cancel(timer)

  showTimeoutModal = ->
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

    countdownInterval = $interval((
      ->
        $scope.countdown -= 1
        $scope.logOff(true) if $scope.countdown == 0
      ), 1000, 10
    )

    $scope.stayLoggedIn = () ->
      $scope.isLoading = true
      $interval.cancel(countdownInterval)
      MnoeCurrentUser.refreshUser().then(
        (response) ->
          $uibModalInstance.close(response)
        (error) ->
          toastr.warning("mno_enterprise.auth.sessions.timeout.error")
          $scope.logOff()
      ).finally(-> $scope.isLoading = false)

    $scope.logOff = (timeout = false) ->
      $uibModalInstance.dismiss('cancel')
      $interval.cancel(countdownInterval)
      $http.delete('/mnoe/auth/users/sign_out')

      url = '/mnoe/auth/users/sign_in'
      url += '?session_timeout=true' if timeout
      $window.location.href = url

  return @
