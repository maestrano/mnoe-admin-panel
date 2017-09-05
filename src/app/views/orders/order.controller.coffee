@App.controller 'OrderController', () ->
  'ngInject'
  vm = this

  vm.order = {}

  vm.options = ['yes', 'no']

  return vm
