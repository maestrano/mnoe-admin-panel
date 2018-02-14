@App.controller 'appInfoCtrl', ($uibModalInstance, MnoeAdminConfig, app) ->
  vm = this
  vm.app = app

  # Init pricing plans
  plans = vm.app.pricing_plans
  currency = MnoeAdminConfig.marketplaceCurrency()
  vm.pricing_plans = plans[currency] || plans.AUD || plans.default

  vm.close = ->
    $uibModalInstance.close()

  return
