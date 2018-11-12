
# This service is used to manage the configuration of momentjs.
# Locale strategy in order: User settings, webstore default language, fallback locale.
@App.service('LocaleConfigSvc', ($q, $window, $translate, amMoment, moment, MnoeCurrentUser, MnoeTenant, LOCALES, URI) ->

  @configure = ->
    $q.all(user: localeFromUser(), tenant: localeFromTenant()).then(
      (response) ->
        # Order of array represents order in which locales will be chosen.
        locales = [response.user, response.tenant, LOCALES.fallbackLanguage]
        setAmLocales(locales)
    )

  setAmLocales = (locales) ->
    # No need to filter on available locales, as amMoment automatically loads locales.
    amMoment.changeLocale(locales.find((l) -> !!l))

  # Find the locale from the User#settings
  localeFromUser = ->
    MnoeCurrentUser.getUser().then((response) ->
      response.settings?.locale
    )

  # Find the locale from the Tenant#settings
  localeFromTenant = ->
    MnoeTenant.get().then((response) ->
      response.data?.frontend_config?.system?.i18n?.preferred_locale
    )

  return @
)
