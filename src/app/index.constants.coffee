@App
  .constant('USER_ROLES', [
    {value: 'Member', label: 'mnoe_admin_panel.constants.user_roles.member'},
    {value: 'Power User', label: 'mnoe_admin_panel.constants.user_roles.power_user'},
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
    })
  .constant('LOCALES', {
    locales: [
      { id: 'en-AU', name: 'English (Australia)' }
    ],
    preferredLanguage: 'en-AU',
    fallbackLanguage: 'en-AU'
  })
