@App

  # Load the app name title
  .run(($rootScope, APP_NAME) ->
    $rootScope.app_name = APP_NAME
  )

  # Change title on state change - to use ng-bind and make it update with translations
  .run(($rootScope, $log) ->
    $rootScope.$on('$stateChangeStart', (event, toState, toParams, fromState, fromParams) ->
      $rootScope.pageTitle = toState.data.pageTitle
    )
  )

  # Force the page to scroll to top when a view change
  .run(($rootScope) ->
    $rootScope.$on('$viewContentLoaded', ->
      window.scrollTo(0, 0)
    )
  )

  # Override the default toastr template to use angular-translate
  .run(($templateCache) ->
    $templateCache.put('directives/toast/toast.html', '''
        <div class="{{toastClass}} {{toastType}}" ng-click="tapToast()">
          <div ng-switch on="allowHtml">
            <div ng-switch-default ng-if="title" class="{{titleClass}}" aria-label="{{title | translate}}">{{title | translate:extraData}}</div>
            <div ng-switch-default class="{{messageClass}}" aria-label="{{message | translate:extraData}}">{{message | translate:extraData}}</div>
            <div ng-switch-when="true" ng-if="title" class="{{titleClass}}" ng-bind-html="title | translate:extraData"></div>
            <div ng-switch-when="true" class="{{messageClass}}" ng-bind-html="message | translate:extraData"></div>
          </div>
          <progress-bar ng-if="progressBar"></progress-bar>
        </div>
        '''
    )
  )

  # Display flash messages from the backend in toastr
  # They're passed this way:
  #   ?flash={"msg":"An error message.","type":"error"}
  .run((toastr, $location) ->
    if flash = $location.search().flash
      message = JSON.parse(flash)
      toastr[message.type](message.msg, _.capitalize(message.type), timeout: 10000)
      $location.search('flash', null) # remove the flash from url
  )

  # Intercom
  .run(($rootScope, $timeout, IntercomSvc, MnoeCurrentUser) ->
    # Init Intercom once app is loaded
    $timeout(->
      MnoeCurrentUser.getUser().then((user) -> IntercomSvc.init(user))
    )

    # Track page change
    $rootScope.$on("$stateChangeStart", -> IntercomSvc.update())
  )

  # xeditable-angular configuration
  .run((editableOptions) ->
    # bootstrap3 theme. Can be also 'bs2', 'default'
    editableOptions.theme = 'bs3'
  )

  # Configure angular translate depending on the locale used in the path
  .run((LocaleConfigSvc) ->
    LocaleConfigSvc.configure()
  )
