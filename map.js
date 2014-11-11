// Our Javascript will go here.
var makePlaneGeometry = function(width, height, widthSegments, heightSegments) {
    var geometry = new THREE.PlaneGeometry(width, height, widthSegments, heightSegments);
    var X_OFFSET_DAMPEN = 0.3;
    var Y_OFFSET_DAMPEN = 0.1;
    var Z_OFFSET_DAMPEN = 0.9;
    var randSign = function() { return (Math.random() > 0.5) ? 1 : -1; };

    for (var vertIndex = 0; vertIndex < geometry.vertices.length; vertIndex++) {
        geometry.vertices[vertIndex].x += Math.random() / X_OFFSET_DAMPEN * randSign();
        geometry.vertices[vertIndex].y += Math.random() / Y_OFFSET_DAMPEN * randSign();
        geometry.vertices[vertIndex].z += Math.random() / Z_OFFSET_DAMPEN * randSign();
    }

    geometry.dynamic = true;
    geometry.computeFaceNormals();
    geometry.computeVertexNormals();
    geometry.normalsNeedUpdate = true;
    return geometry;
};

var makePlane = function(geometry) {
    //var material = new THREE.MeshBasicMaterial({color: 0xB8B7BA, wireframe: true});
    var material = new THREE.MeshLambertMaterial({
        color: 0xffffff,
        shading: THREE.FlatShading
    });
    var plane = new THREE.Mesh(geometry, material);
    return plane;
};

var makeLights = function(scene) {
    var ambientLight = new THREE.AmbientLight(0x1a1a1a);
    scene.add(ambientLight);

    var dirLight = new THREE.DirectionalLight(0xdfe8ef, 0.09);
    dirLight.position.set(5, 2, 1);
    scene.add(dirLight);
};
var makeScene = function(renderer) {
    var scene = new THREE.Scene();
    scene.fog = new THREE.FogExp2(0xffffff, 0.01);
    makeLights(scene);

    document.body.appendChild( renderer.domElement );
    return scene;
};

var makeCamera = function () {
    var fov = 40;
    var aspectRatio = window.innerWidth / window.innerHeight;
    var zPos = 10;

    var camera = new THREE.PerspectiveCamera(fov, aspectRatio, 0.1, 1000);
    camera.up = new THREE.Vector3(0, 1, 0);
    camera.rotation.x = 75 * Math.PI / 180;
    camera.position.z = zPos;

    return camera;
};

var makeRenderer = function () {
    var renderer = new THREE.WebGLRenderer({
        antialiasing: true,
        alpha: true
    });
    renderer.setSize( window.innerWidth, window.innerHeight );

    return renderer;
};

var makeParticles = function (scene) {
    // create the particle variables
    var particleCount = 1800,
	particles = new THREE.Geometry(),
	pMaterial = new THREE.PointCloudMaterial({
	    color: 0x4378DD,
	    size: 2,
	    transparent: true
	});

    // now create the individual particles
    for(var p = 0; p < particleCount; p++) {

	// create a particle with random
	// position values, -250 -> 250
	var pX = Math.random() * 500 - 250,
	    pY = Math.random() * 500 - 250,
	    pZ = Math.random() * 500 - 250,
	    particle = new THREE.Vector3(pX, pY, pZ);
	// create a velocity vector
        var speed = Math.abs(Math.random() * 0.01);
	particle.velocity = new THREE.Vector3(speed, -speed,0);

	// add it to the geometry
	particles.vertices.push(particle);
    }

    // create the particle system
    var particleSystem = new THREE.PointCloud(
	particles,
	pMaterial);

    particleSystem.sortParticles = true;

    // add it to the scene
    scene.add(particleSystem);

    return {
        particles: particles,
        particleSystem: particleSystem,
        particleCount: particleCount
    };
};

var render = function (renderer, scene, camera, p, time) {
    // animation loop
    var particleSystem = p.particleSystem;
    var particles = p.particles;

    // add some rotation to the system
    particleSystem.rotation.y += 0.01;

    var pCount = p.particleCount;
    while(pCount--) {
	// get the particle
	var particle = particles.vertices[pCount];

	// check if we need to reset
	if(particle.y < -200) {
	    particle.y = 200;
	    particle.velocity.y = 0;
	}

	// update the velocity
	particle.velocity.y -= Math.random() * .01;

	// and the position
	particle.add(particle.velocity);
    }

    // flag to the particle system that we've
    // changed its vertices. This is the
    // dirty little secret.
    particleSystem.geometry.__dirtyVertices = true;

    renderer.render(scene, camera);

    // set up the next call
    requestAnimationFrame( render.bind(null, renderer, scene, camera, p) );
};

var init = function(container, viewWidth, viewHeight) {
    var renderer = makeRenderer();
    var scene = makeScene(renderer);
    var camera = makeCamera();
    var particles = makeParticles(scene);

    var plane = makePlane(makePlaneGeometry(400, 400, 100, 100));

    scene.add(plane);

    render(renderer, scene, camera, particles);
};

init();
