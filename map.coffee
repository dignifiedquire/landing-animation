
class Animation
  constructor: () ->
    @makeRenderer()
    @makeScene()
    @makeCamera()
    @makeParticles()

    @makePlaneGeometry(400, 400, 100, 100)
    @makePlane()

    @scene.add @plane

    @render()


  makePlaneGeometry: (width, height, widthSegments, heightSegments) ->
    @geometry = new THREE.PlaneGeometry(width, height, widthSegments, heightSegments)
    X_OFFSET_DAMPEN = 0.3
    Y_OFFSET_DAMPEN = 0.3
    Z_OFFSET_DAMPEN = 0.8
    randSign = -> if Math.random() > 0.5 then 1 else -1

    for vertex in @geometry.vertices
      vertex.x += Math.random() / X_OFFSET_DAMPEN * randSign()
      vertex.y += Math.random() / Y_OFFSET_DAMPEN * randSign()
      vertex.z += Math.random() / Z_OFFSET_DAMPEN * randSign()

    @geometry.dynamic = true
    @geometry.computeFaceNormals()
    @geometry.computeVertexNormals()
    @geometry.normalsNeedUpdate = true


  makePlane: () ->
    #material = new THREE.MeshBasicMaterial(color: 0xB8B7BA, wireframe: true)
    @material = new THREE.MeshLambertMaterial
      color: 0xeeeeee
      shading: THREE.FlatShading

    @plane = new THREE.Mesh(@geometry, @material)


  makeLights: () ->
    ambientLight = new THREE.AmbientLight(0x4378DD)#0x1a1a1a)

    @scene.add ambientLight

    dirLight = new THREE.DirectionalLight(0xdfe8ef, 0.12)
    dirLight.position.set(5, 2, 1)

    @scene.add dirLight

  makeScene: () ->
    @scene = new THREE.Scene()
    @scene.fog = new THREE.FogExp2(0xffffff, 0.014)

    @makeLights()

    document.body.appendChild( @renderer.domElement )

  degree: (radian) -> radian * 180 / Math.PI

  calculateFov: (renderWidth, renderHeight, distance) ->

    vFOV1 = 2 * Math.atan( renderWidth / ( 2 * distance ) )
    vFOV2 = 2 * Math.atan( renderHeight / ( 2 * distance ) )

    if vFOV1 > vFOV2 then @degree(vFOV1) else @degree(vFOV2)

  makeCamera: () ->
    aspectRatio = window.innerWidth / window.innerHeight
    zPos = 8
    distance = 1000
    fov = @calculateFov window.innerWidth, window.innerHeight, distance

    @camera = new THREE.PerspectiveCamera(fov, aspectRatio, 0.1, distance)
    @camera.up = new THREE.Vector3(0, 1, 0)
    @camera.rotation.x = 75 * Math.PI / 180
    @camera.position.z = zPos


  makeRenderer: ->
    @renderer = new THREE.WebGLRenderer
        antialiasing: true
        alpha: true

    @renderer.setSize( window.innerWidth, window.innerHeight )


  makeParticles: () ->
    # create the particle variables
    @particleCount = 1800
    @particles = new THREE.Geometry()
    pMaterial = new THREE.PointCloudMaterial
      color: 0xc5d5f4
      size: 2
      transparent: false


    # now create the individual particles
    for p in [1..@particleCount]

      # create a particle with random
      # position values, -250 -> 250
      pX = Math.random() * 500 - 250
      pY = Math.random() * 100 - 25
      pZ = Math.random() * 250 - 50

      particle = new THREE.Vector3(pX, pY, pZ)

      # create a velocity vector
      speed = Math.abs(Math.random() * 0.01)
      particle.velocity = new THREE.Vector3(speed, -speed, 0)

      # add it to the geometry
      @particles.vertices.push(particle)

    # create the particle system
    @particleSystem = new THREE.PointCloud(@particles, pMaterial)
    @particleSystem.sortParticles = true

    # add it to the scene
    @scene.add @particleSystem

  render: (time) ->
    # animation loop

    # add some rotation to the system
    #@particleSystem.rotation.x += 0.01

    pCount = @particleCount
    while(pCount--)
      # get the particle
      particle = @particles.vertices[pCount]

      # check if we need to reset
      if particle.y < 0
        particle.y = 200
        particle.velocity.y = 0

      # update the velocity
      particle.velocity.y -= Math.random() * .01

      # and the position
      particle.add particle.velocity

    # flag to the particle system that we've
    # changed its vertices. This is the
    # dirty little secret.
    @particleSystem.geometry.__dirtyVertices = true

    @renderer.render(@scene, @camera)

    # set up the next call
    requestAnimationFrame @render.bind this


animation = new Animation()

