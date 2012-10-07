class Stage
  constructor: ->
    @frame = 0
    @map = [
      ['Q','W','E','R','T','Y','U','I','O','P']
      ['A','S','D','F','G','H','J','K','L']
      ['Z','X','C','V','B','N','M']
    ]
    @scene = new THREE.Scene()
    @scene.fog = new THREE.Fog(0x000000, 250, 2400);
    
    @positions = {}
    @all = []
    for z, row of @map
      for x, cell of @map[z]
        text = new Text(cell, x, z)
        @all.push(text)
        @positions[cell] = text
        @scene.add(text.mesh)
    
    @camera = new THREE.PerspectiveCamera(40, document.width / document.height, 1, 10000)
    @camera.position.y = 300
    @camera.position.z = 1000
    
    @renderer = new THREE.WebGLRenderer({antialias: true})
    @renderer.setSize(document.width, document.height)
    @renderer.setClearColor(@scene.fog.color, 1)
    document.body.appendChild(@renderer.domElement)
    
    light = new THREE.DirectionalLight(0xFFFFFF)
    light.position = {x:100, y:1000, z:1000}
    @scene.add(light)
    @pointLight = new THREE.PointLight(0xffffff, 1.5)
    @pointLight.position.set(0, 100, 90)
    @pointLight.color.setHSV(Math.random(), 0.95, 0.85)
    @scene.add(@pointLight)
    
    @control = new THREE.TrackballControls(@camera, @renderer.domElement)
    @projector = new THREE.Projector()
    
    plane = new THREE.Mesh(
      new THREE.PlaneGeometry(10000, 10000),
      new THREE.MeshBasicMaterial({
        color: 0xffffff,
        opacity: 0.8,
        transparent: true
      })
    )
    plane.position.y = 100
    plane.rotation.x = - Math.PI / 2
    @scene.add(plane)
    
  render: ->
    if Math.random() <= 0.1
      index = parseInt(Math.random() * @all.length)
      unless @all[index].jumping
        @all[index].jump()
    @control.update()
    TWEEN.update()
    @renderer.render(@scene, @camera)

class Text
  faceMaterial = new THREE.MeshFaceMaterial()
  textMaterialFront = new THREE.MeshBasicMaterial({
    color: 0x00ff00,
    opacity: 1,
  })
  textMaterialSide = new THREE.MeshBasicMaterial({
    color: 0x33ff33,
  })
  textHitMaterialFront = new THREE.MeshBasicMaterial({
    color: 0xff0000,
    opacity: 1,
  })
  textHitMaterialSide = new THREE.MeshBasicMaterial({
    color: 0xff3333,
  })
  
  geometoryConf = {
    size: 70,
    height: 20,
    curveSegments: 4,
    font: "optimer",
    weight: "bold",
    style: "normal",
    material: 0,
    extrudeMaterial: 1
  }
  constructor: (char, x, z)->
    @char = char
    @jumping = false
    textGeo = new THREE.TextGeometry(@char, geometoryConf)
    textGeo.materials = [textMaterialFront, textMaterialSide]
    textGeo.computeBoundingBox()
    textGeo.computeVertexNormals()
    
    centerOffset = -0.5 * (textGeo.boundingBox.max.x - textGeo.boundingBox.min.x)
    textMesh1 = new THREE.Mesh(textGeo, faceMaterial)
    textMesh1.position = {x: centerOffset + (x * 110) - 500, y: 0, z: z * 150}
    textMesh1.rotation.x = 0
    textMesh1.rotation.y = Math.PI * 2
    @mesh = textMesh1
  jump: ->
    @jumping = true
    to = (Math.random() * 100) + 100
    @tween = new TWEEN.Tween(@mesh.position).to({y: to}, 1000).onComplete(=> 
      new TWEEN.Tween(
        @mesh.position
      ).to({y: 0}, 1000).onComplete(=>
        @jumping = false
      ).easing(TWEEN.Easing.Quintic.EaseOut).start()
    ).easing(TWEEN.Easing.Quintic.EaseOut).start()
    
  hit: =>
    if @jumping
      @jumping = false
      window.pointAdd(@char)
      @mesh.geometry.materials = [textHitMaterialFront, textHitMaterialSide]
      setTimeout(=>
        @mesh.geometry.materials = [textMaterialFront, textMaterialSide]
      , 500)

@stage = new Stage()
@addEventListener "DOMContentLoaded", ->
  @stage.render()
  ((stage) ->
    setInterval ->
      stage.render()
    , 100
  ) @stage

@pointAdd = (char)=>
  point = @document.getElementById('point').innerHTML
  @document.getElementById('point').innerHTML = parseInt(point) + 1

@document.onkeydown = (e) =>
  char = String.fromCharCode(e.keyCode)
  char = char.toUpperCase()
  @stage.positions[char]?.hit?()