@App
  .constant('USER_ROLES', [
    {value: 'Member', label: 'mnoe_admin_panel.constants.user_roles.member'},
    {value: 'Admin', label: 'mnoe_admin_panel.constants.user_roles.admin'},
    {value: 'Super Admin', label: 'mnoe_admin_panel.constants.user_roles.super_admin'}
  ])
  .constant('ADMIN_ROLES', [
    {value: 'admin', label: 'mnoe_admin_panel.constants.admin_roles.admin'},
    {value: 'sub_tenant_admin', label: 'mnoe_admin_panel.constants.admin_roles.sub_tenant_admin'},
    {value: 'staff', label: 'mnoe_admin_panel.constants.admin_roles.staff'},
    {value: 'support', label: 'mnoe_admin_panel.constants.admin_roles.support'}
  ])  # Must be lower case
  .constant('STAFF_PAGE_AUTH', ['admin', 'sub_tenant_admin'])
  .constant('OBS_KEYS', {
    organizationChanged: 'organizationListChanged',
    userChanged: 'userListChanged',
    staffChanged: 'staffListChanged',
    staffAdded: 'staffAdded',
    subTenantAdded: 'subTenantAdded',
    subTenantChanged: 'subTenantListChanged',
    marketplaceChanged: 'marketplaceChanged',
    subscriptionEventChanged: 'subscriptionEventChanged',
    orgChanged: 'organizationChanged'
  })
  .constant('LOCALES', {
    locales: [
      { id: 'en-AU', name: 'English (Australia)' }
      { id: 'en-US', name: 'English (American)' }
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
  .constant('TRANSACTION_TYPES', [
    {value: 'credit', label: 'mnoe_admin_panel.constants.transaction_types.credit'},
    {value: 'debit', label: 'mnoe_admin_panel.constants.transaction_types.debit'}
  ])
