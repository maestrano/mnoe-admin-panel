@App

  # Load the app name title
  .run(($rootScope, APP_NAME) ->
    $rootScope.app_name = APP_NAME
  )

  # Force the page to scroll to top when a view change
  .run(($rootScope) ->
    $rootScope.$on('$viewContentLoaded', ->
      window.scrollTo(0, 0)
    )
  )

  # Override the default toastr template to use angular-translate
  .run(($templateCache) ->
    $templateCache.put('directives/toast/toast.html',
      '''
      <div class="{{toastClass}} {{toastType}}" ng-click="tapToast()">
        <div ng-switch on="allowHtml">
          <div ng-switch-default ng-if="title" class="{{titleClass}}" aria-label="{{title | translate}}">{{title | translate}}</div>
          <div ng-switch-default class="{{messageClass}}" aria-label="{{message | translate:extraData}}">{{message | translate:extraData}}</div>
          <div ng-switch-when="true" ng-if="title" class="{{titleClass}}" ng-bind-html="title"></div>
          <div ng-switch-when="true" class="{{messageClass}}" ng-bind-html="message"></div>
        </div>
        <progress-bar ng-if="progressBar"></progress-bar>
      </div>
      '''
    )
  )
