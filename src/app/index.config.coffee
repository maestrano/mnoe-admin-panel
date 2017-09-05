@App
  .config(($logProvider, toastrConfig) ->
    # Enable log
    $logProvider.debugEnabled true
    # Set options third-party lib
    toastrConfig.timeOut = 3000
    toastrConfig.positionClass = 'toast-top-right'
    toastrConfig.preventDuplicates = false
    toastrConfig.progressBar = true
  )

  .config(($httpProvider) ->
    $httpProvider.interceptors.push(($q, $window, $injector, $log) ->
      return {
        responseError: (rejection) ->

          if rejection.status == 401
            # Inject the toastr service (avoid circular dependency)
            toastr = $injector.get('toastr')

            # Redirect the user to the dashboard or login screen
            $window.location.href = "/"

            # Display an error
            toastr.error("You are no longer connected or not an administrator, you will be redirected to the dashboard.")
            $log.error("User is not connected!")

          $q.reject rejection
      }
    )
  )

  # Configure textAngular
  .config(($provide) ->
    $provide.decorator('taOptions',
      ['$delegate', (taOptions) ->
        # $delegate is the taOptions we are decorating
        # Here we override the default toolbars and classes specified in taOptions.
        taOptions.toolbar = [
          ['h1', 'h2', 'h3', 'p', 'quote'], ['bold', 'italics', 'underline', 'ul', 'ol'], ['html']
          ['insertVideo', 'insertImage', 'insertLink'], ['undo', 'redo', 'clear'], ['wordcount', 'charcount']
        ]
        return taOptions
      ]
    )
  )

  .config(($translateProvider, LOCALES) ->
    # Path to translations files
    $translateProvider.useStaticFilesLoader({
      prefix: 'locales/',
      suffix: '.json'
    })

    # language strategy
    $translateProvider.preferredLanguage(LOCALES.preferredLanguage)
    $translateProvider.fallbackLanguage(LOCALES.fallbackLanguage)
    $translateProvider.useMissingTranslationHandlerLog()
    $translateProvider.useSanitizeValueStrategy('sanitize')
    $translateProvider.useMessageFormatInterpolation()

    # remember language
    # $translateProvider.useLocalStorage()
  )

  # Overwrite default template for i18n purpose
  .config(($breadcrumbProvider) ->
    $breadcrumbProvider.setOptions({
      template: '''
        <ol class="breadcrumb">
          <li ng-repeat="step in steps" ng-class="{active: $last}" ng-switch="$last || !!step.abstract">
            <a ng-switch-when="false" href="{{step.ncyBreadcrumbLink}}">{{step.ncyBreadcrumbLabel | translate}}</a>
          <span ng-switch-when="true">{{step.ncyBreadcrumbLabel | translate}}</span>
          </li>
        </ol>
    '''
    })
  )
