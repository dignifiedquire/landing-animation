
class Animation

  makePlaneGeometry: (width, height, widthSegments, heightSegments) ->
    @geometry = new THREE.PlaneGeometry(width, height, widthSegments, heightSegments)
    X_OFFSET_DAMPEN = 0.3
    Y_OFFSET_DAMPEN = 0.1
    Z_OFFSET_DAMPEN = 0.9
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
      color: 0xffffff
      shading: THREE.FlatShading

    @plane = new THREE.Mesh(@geometry, @material)


  makeLights: () ->
    ambientLight = new THREE.AmbientLight(0x1a1a1a)

    @scene.add ambientLight

    dirLight = new THREE.DirectionalLight(0xdfe8ef, 0.09)
    dirLight.position.set(5, 2, 1)

    @scene.add dirLight

  makeScene: () ->
    @scene = new THREE.Scene()
    @scene.fog = new THREE.FogExp2(0xffffff, 0.02)

    @makeLights()

    document.body.appendChild( @renderer.domElement )


  makeCamera: () ->
    aspectRatio = window.innerWidth / window.innerHeight
    fov = 30
    zPos = 10

    @camera = new THREE.PerspectiveCamera(fov, aspectRatio, 0.1, 1000)
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
      color: 0x4378DD
      size: 2
      transparent: true


    # now create the individual particles
    for p in [1..@particleCount]

      # create a particle with random
      # position values, -250 -> 250
      pX = Math.random() * 500 - 250
      pY = Math.random() * 500 - 250
      pZ = Math.random() * 500 - 250

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
    @particleSystem.rotation.y += 0.01

    pCount = @particleCount
    while(pCount--)
      # get the particle
      particle = @particles.vertices[pCount]

      # check if we need to reset
      if particle.y < -200
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


  start: (container, viewWidth, viewHeight) ->
    @makeRenderer()
    @makeScene()
    @makeCamera()
    @makeParticles()

    @makePlaneGeometry(400, 400, 100, 100)
    @makePlane()

    @scene.add @plane

    @render()


animation = new Animation()
animation.start()
