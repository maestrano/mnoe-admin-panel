@App
  .constant('USER_ROLES', [
    {value: 'Member', label: 'mnoe_admin_panel.constants.user_roles.member'},
    {value: 'Admin', label: 'mnoe_admin_panel.constants.user_roles.admin'},
    {value: 'Super Admin', label: 'mnoe_admin_panel.constants.user_roles.super_admin'}
  ])
  .constant('ADMIN_ROLES', [
    {value: 'admin', label: 'mnoe_admin_panel.constants.admin_roles.admin'},
    {value: 'sub_tenant_admin', label: 'mnoe_admin_panel.constants.admin_roles.sub_tenant_admin'},
    {value: 'staff', label: 'mnoe_admin_panel.constants.admin_roles.staff'}
  ])  # Must be lower case
  .constant('STAFF_PAGE_AUTH', ['admin', 'sub_tenant_admin'])
  .constant('OBS_KEYS', {
    userChanged: 'userListChanged',
    staffChanged: 'staffListChanged',
    staffAdded: 'staffAdded',
    subTenantAdded: 'subTenantAdded',
    subTenantChanged: 'subTenantListChanged',
    marketplaceChanged: 'marketplaceChanged'
  })
  .constant('LOCALES', {
    locales: [
      { id: 'en-AU', name: 'English (Australia)' }
    ],
    preferredLanguage: 'en-AU',
    fallbackLanguage: 'en-AU'
  })
  .constant('CURRENCIES', {
    values: ['USD','AUD','CAD','CNY','EUR','GBP','HKD','INR','JPY','NZD', 'SGD', 'PHP', 'AED']
  })
  .constant('URI', {
    login: '/mnoe/auth/users/sign_in',
    logout: '/mnoe/auth/users/sign_out',
  })
  .constant('PRICING_TYPES', {
    'unpriced': ['free', 'payg']
  })
  .constant('EDIT_ACTIONS', {
    'NEW': 'mnoe_admin_panel.dashboard.provisioning.subscriptions.new'
    'EDIT': 'mnoe_admin_panel.dashboard.provisioning.subscriptions.edit',
    'CHANGE': 'mnoe_admin_panel.dashboard.provisioning.subscriptions.change',
    'RENEW': 'mnoe_admin_panel.dashboard.provisioning.subscriptions.renew',
    'SUSPEND': 'mnoe_admin_panel.dashboard.provisioning.subscriptions.suspend',
    'REACTIVATE': 'mnoe_admin_panel.dashboard.provisioning.subscriptions.reactivate'
  })
