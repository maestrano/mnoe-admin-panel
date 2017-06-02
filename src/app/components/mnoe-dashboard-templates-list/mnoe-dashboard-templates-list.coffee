#
# Mnoe Dashboard Templates list
#
@App.component('mnoeDashboardTemplatesList', {
  templateUrl: 'app/components/mnoe-dashboard-templates-list/mnoe-dashboard-templates-list.html',
  bindings: {}
  controller: ($uibModal, MnoeDashboardTemplates) ->
    vm = this

    vm.dashboardTemplates = {}

    vm.callServer = () ->
      fetchDashboardTemplates()

    #====================================
    # Dashboard Template deletion Modal
    #====================================
    vm.openDeleteDashboardTemplate = (dashboardTemplate) ->
      modalInstance = $uibModal.open(
        templateUrl: 'app/views/dashboard-templates/modals/delete-dashboard-template-modal.html'
        controller: 'deleteDashboardTemplateCtrl'
        size: 'lg'
        resolve:
          dashboardTemplate: dashboardTemplate
      ).closed.then(-> fetchDashboardTemplates())

    # Fetch dashboard templates
    fetchDashboardTemplates = () ->
      vm.dashboardTemplates.loading = true
      return MnoeDashboardTemplates.list().then(
        (response) ->
          vm.dashboardTemplates.list = response.data
      ).finally(-> vm.dashboardTemplates.loading = false)

    return
})
