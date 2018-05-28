@App.controller 'AddTransactionModalCtrl', ($uibModalInstance, toastr, TRANSACTION_TYPES, CURRENCIES, MnoeAccountTransactions, organization) ->
  'ngInject'
  vm = this

  vm.TRANSACTION_TYPES = TRANSACTION_TYPES
  vm.currencies = _.clone(CURRENCIES.values)

  vm.onSubmit = () ->
    vm.isLoading = true
    vm.account_transaction.amount_cents = (vm.account_transaction.amount * 100).toFixed(0)
    vm.account_transaction.organization_id = organization.id

    MnoeAccountTransactions.create(vm.account_transaction).then(
      (success) ->
        toastr.success('mnoe_admin_panel.dashboard.organization.accounting_transaction.toastr_success')

        $uibModalInstance.close()
      (error) ->
        toastr.error('mnoe_admin_panel.dashboard.organization.create_user.toastr_error')
        MnoErrorsHandler.processServerError(error)
    ).finally(-> vm.isLoading = false)

  vm.onCancel = () ->
    $uibModalInstance.dismiss('cancel')

  return
