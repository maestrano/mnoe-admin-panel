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

    # Override the default tabs template (JSON schema form) to use angular translate filter
    $templateCache.put('decorators/bootstrap/tabs.html', '''
        <div ng-init="selected = { tab: 0 }" class="schema-form-tabs {{form.htmlClass}}">
        <ul class="nav nav-tabs">
          <li ng-repeat="tab in form.tabs"
              ng-disabled="form.readonly"
              ng-click="$event.preventDefault() || (selected.tab = $index)"
              ng-class="{active: selected.tab === $index}">
              <a href="#">{{ tab.title | translate }}</a>
          </li>
        </ul>

        <div class="tab-content {{form.fieldHtmlClass}}">
        </div>
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
