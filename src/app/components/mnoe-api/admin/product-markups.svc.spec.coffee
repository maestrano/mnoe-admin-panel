describe('Service: MnoeProductMarkups', ->

  beforeEach(module('frontendAdmin'))

  $httpBackend = null
  MnoeProductMarkups = null

  beforeEach(inject((_MnoeProductMarkups_, _$httpBackend_) ->
    MnoeProductMarkups = _MnoeProductMarkups_
    $httpBackend = _$httpBackend_

    # Backend interceptors
    $httpBackend.when('GET', '/mnoe/jpi/v1/admin/product_markups').respond(200,
      {
        "product_markups": [
          { "id": 9, "percentage": "0.11", "product_name": "App 1", "organization_name": "Cool Org", "created_at": "2015-11-01T03:26:16.000Z" },
          { "id": 10, "percentage": "0.32", "product_name": "App 2", "organization_name": "Coolest Org", "created_at": "2015-11-01T03:27:16.000Z" }
        ]
      })

    # Backend interceptors
    $httpBackend.when('GET', '/mnoe/jpi/v1/admin/product_markups/10').respond(200,
      {
        "product_markups": [
          { "id": 10, "percentage": "0.32", "product_name": "App 2", "organization_name": "Coolest Org", "created_at": "2015-11-01T03:27:16.000Z" }
        ]
      })

  ))

  afterEach( ->
    $httpBackend.verifyNoOutstandingExpectation()
    $httpBackend.verifyNoOutstandingRequest()
  )

  describe('@list', ->
    it('GETs /mnoe/jpi/v1/admin/product_markups', ->
      $httpBackend.expectGET('/mnoe/jpi/v1/admin/product_markups')
      MnoeProductMarkups.list()
      $httpBackend.flush()
    )
  )

  describe('@get', ->
    it('GETs /mnoe/jpi/v1/admin/product_markups/10', ->
      $httpBackend.expectGET('/mnoe/jpi/v1/admin/product_markups/10')
      MnoeProductMarkups.get(10)
      $httpBackend.flush()
    )
  )
)
