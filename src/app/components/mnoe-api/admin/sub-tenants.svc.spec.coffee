describe('Service: MnoeSubTenants', ->

  beforeEach(module('frontendAdmin'))

  $httpBackend = null
  MnoeSubTenants = null

  beforeEach(inject((_MnoeSubTenants_, _$httpBackend_) ->
    MnoeSubTenants = _MnoeSubTenants_
    $httpBackend = _$httpBackend_

    # Backend interceptors
    $httpBackend.when('GET', '/mnoe/jpi/v1/admin/sub_tenants').respond(200,
      {
        "sub_tenants": [
          { "id": 9, "name": "Marvel" },
          { "id": 10, "name": "DC Comics" }
        ]
      })

    # Backend interceptors
    $httpBackend.when('GET', '/mnoe/jpi/v1/admin/sub_tenants/1').respond(200,
      {
        "sub_tenant": [
          { "id": 1, "name": "Marvel" , "clients": [{"id": 9, "uid": "usr-fbbw", "name": "Marvel"}]}
        ]
      })

  ))

  afterEach( ->
    $httpBackend.verifyNoOutstandingExpectation()
    $httpBackend.verifyNoOutstandingRequest()
  )

  describe('@list', ->
    it('GETs /mnoe/jpi/v1/admin/sub_tenants', ->
      $httpBackend.expectGET('/mnoe/jpi/v1/admin/sub_tenants')
      MnoeSubTenants.list()
      $httpBackend.flush()
    )
  )

  describe('@get', ->
    it('GETs /mnoe/jpi/v1/admin/sub_tenants/1', ->
      $httpBackend.expectGET('/mnoe/jpi/v1/admin/sub_tenants/1')
      MnoeUsers.get(1)
      $httpBackend.flush()
    )
  )
)
