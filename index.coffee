DEBUG = false
SPEED = 490
GRAVITY = 2000
FLAP = 620
SPAWN_RATE = 1 / 1
OPENING = 134
SCALE = 1

parent = document.querySelector("#screen")
gameStarted = undefined
gameOver = undefined
score = undefined
bg = undefined
credits = undefined
# clouds = undefined
tubes = undefined
invs = undefined
bird = undefined
ground = undefined
scoreText = undefined
instText = undefined
gameOverText = undefined
flapSnd = undefined
scoreSnd = undefined
hurtSnd = undefined
tubesTimer = undefined
# cloudsTimer = undefined



# spawnCloud = ->
#   cloudsTimer.stop()
#   cloudY = Math.random() * game.height / 2
#   cloud = clouds.create(game.width, cloudY, "clouds", Math.floor(4 * Math.random()))
#   cloudScale = 2 + 2 * Math.random()
#   cloud.alpha = 2 / cloudScale
#   cloud.scale.setTo cloudScale, cloudScale
#   cloud.body.allowGravity = false
#   cloud.body.velocity.x = -SPEED / cloudScale
#   cloud.anchor.y = 0
#   cloudsTimer.start()
#   cloudsTimer.add 4 * Math.random()
#   return
o = ->
  OPENING

spawntube = (tubeY, flipped) ->
  tube = tubes.create(game.width, tubeY + ((if flipped then -o() else o())) / 2, "tube")
  tube.body.allowGravity = false

  # Flip tube! *GASP*
  tube.scale.setTo SCALE, (if flipped then -SCALE else SCALE)
  tube.body.offset.y = (if flipped then -tube.body.height * 2 else 0)

  # Move to the left
  tube.body.velocity.x = -SPEED
  tube

spawntubes = ->
  tubesTimer.stop()
  tubeY = ((game.height - 16 - o() / 2) / 2) + ((if Math.random() > 0.5 then -1 else 1)) * Math.random() * game.height / 6

  # Bottom tube
  bottube = spawntube(tubeY)

  # Top tube (flipped)
  toptube = spawntube(tubeY, true)

  # Add invisible thingy
  inv = invs.create(toptube.x + toptube.width, 0)
  inv.width = 2
  inv.height = game.world.height
  inv.body.allowGravity = false
  inv.body.velocity.x = -SPEED
  tubesTimer.add 1 / SPAWN_RATE, spawntubes
  tubesTimer.start()
  return

addScore = (_, inv) ->
  invs.remove inv
  score += 1
  scoreText.setText score
  scoreSnd.play()
  return

setGameOver = ->
  gameOver = true
  instText.setText "TOUCH bird\nTO TRY AGAIN"
  instText.renderable = true
  hiscore = window.localStorage.getItem("hiscore")
  hiscore = (if hiscore then hiscore else score)
  hiscore = (if score > parseInt(hiscore, 10) then score else hiscore)
  window.localStorage.setItem "hiscore", hiscore
  gameOverText.setText "GAMEOVER\n\nHIGH SCORE\n" + hiscore
  gameOverText.renderable = true

  # Stop all tubes
  tubes.forEachAlive (tube) ->
    tube.body.velocity.x = 0
    return

  invs.forEach (inv) ->
    inv.body.velocity.x = 0
    return


  # Stop spawning tubes
  tubesTimer.stop()

  # Make bird reset the game
  bird.events.onInputDown.addOnce reset
  hurtSnd.play()
  return

flap = ->
  start()  unless gameStarted
  unless gameOver
    bird.body.velocity.y = -FLAP
    flapSnd.play()
  return

preload = ->
  assets =
    spritesheet:
      bird: [
        "assets/bird.png"
        36
        26
      ]

    image:
      tube: ["assets/tube1.png"]
      ground: ["assets/ground.png"]

    audio:
      flap: ["assets/sfx_wing.mp3"]
      score: ["assets/sfx_point.mp3"]
      hurt: ["assets/sfx_hit.mp3"]

  Object.keys(assets).forEach (type) ->
    Object.keys(assets[type]).forEach (id) ->
      game.load[type].apply game.load, [id].concat(assets[type][id])
      return

    return

  return

create = ->

  # Set world dimensions
  screenWidth = (if parent.clientWidth > window.innerWidth then window.innerWidth else parent.clientWidth)
  screenHeight = (if parent.clientHeight > window.innerHeight then window.innerHeight else parent.clientHeight)
  game.world.width = screenWidth
  game.world.height = screenHeight

  # Draw bg
  bg = game.add.graphics(0, 0)
  bg.beginFill 0xDDEEFF, 1
  bg.drawRect 0, 0, game.world.width, game.world.height
  bg.endFill()

  # Credits 'yo
  credits = game.add.text(game.world.width / 2, 10, "",
    font: "8px \"Verdana\""
    fill: "#fff"
    align: "center"
  )
  credits.anchor.x = 0.5

  # # Add clouds group
  # clouds = game.add.group()

  # Add tubes
  tubes = game.add.group()

  # Add invisible thingies
  invs = game.add.group()

  # Add bird
  bird = game.add.sprite(0, 0, "bird")
  bird.anchor.setTo 0.5, 0.5
  bird.animations.add "fly", [
    0
    1
    2
  ], 10, true
  bird.inputEnabled = true
  bird.body.collideWorldBounds = true
  bird.body.gravity.y = GRAVITY

  # Add ground
  ground = game.add.tileSprite(0, game.world.height - 32, game.world.width, 32, "ground")
  ground.tileScale.setTo SCALE, SCALE

  # Add score text
  scoreText = game.add.text(game.world.width / 2, game.world.height / 4, "",
    font: "16px \"Verdana\""
    fill: "#fff"
    stroke: "#430"
    strokeThickness: 4
    align: "center"
  )
  scoreText.anchor.setTo 0.5, 0.5

  # Add instructions text
  instText = game.add.text(game.world.width / 2, game.world.height - game.world.height / 4, "",
    font: "8px \"Verdana\""
    fill: "#fff"
    stroke: "#430"
    strokeThickness: 4
    align: "center"
  )
  instText.anchor.setTo 0.5, 0.5

  # Add game over text
  gameOverText = game.add.text(game.world.width / 2, game.world.height / 2, "",
    font: "16px \"Verdana\""
    fill: "#fff"
    stroke: "#430"
    strokeThickness: 4
    align: "center"
  )
  gameOverText.anchor.setTo 0.5, 0.5
  gameOverText.scale.setTo SCALE, SCALE

  # Add sounds
  flapSnd = game.add.audio("flap")
  scoreSnd = game.add.audio("score")
  hurtSnd = game.add.audio("hurt")

  # Add controls
  game.input.onDown.add flap

  # # Start clouds timer
  # cloudsTimer = new Phaser.Timer(game)
  # cloudsTimer.onEvent.add spawnCloud
  # cloudsTimer.start()
  # cloudsTimer.add Math.random()

  # RESET!
  reset()
  return

reset = ->
  gameStarted = false
  gameOver = false
  score = 0
  credits.renderable = true
  scoreText.setText "Flappy Bird?"
  instText.setText "TOUCH TO FLAP\nbird WINGS"
  gameOverText.renderable = false
  bird.body.allowGravity = false
  bird.angle = 0
  bird.reset game.world.width / 2, game.world.height / 2
  bird.scale.setTo SCALE, SCALE
  bird.animations.play "fly"
  tubes.removeAll()
  invs.removeAll()
  return

start = ->
  credits.renderable = false
  bird.body.allowGravity = true

  # SPAWN tubeS!
  tubesTimer = new Phaser.Timer(game)
  tubesTimer.add 2, spawntubes
  tubesTimer.start()

  # Show score
  scoreText.setText score
  instText.renderable = false

  # START!
  gameStarted = true
  return

update = ->
  if gameStarted

    # Make bird dive
    dvy = FLAP + bird.body.velocity.y
    bird.angle = (90 * dvy / FLAP) - 180
    bird.angle = -30  if bird.angle < -30
    if gameOver or bird.angle > 90 or bird.angle < -90
      bird.angle = 90
      bird.animations.stop()
      bird.frame = 3
    else
      bird.animations.play "fly"

    # bird is DEAD!
    if gameOver
      # bird.scale.setTo bird.scale.x * 1.2, bird.scale.y * 1.2  if bird.scale.x < 4

      # Shake game over text
      gameOverText.angle = Math.random() * 5 * Math.cos(game.time.now / 100)
    else

      # Check game over
      game.physics.overlap bird, tubes, setGameOver
      setGameOver()  if not gameOver and bird.body.bottom >= game.world.bounds.bottom

      # Add score
      game.physics.overlap bird, invs, addScore

    # Remove offscreen tubes
    tubes.forEachAlive (tube) ->
      tube.kill()  if tube.x + tube.width < game.world.bounds.left
      return

  else
    bird.y = (game.world.height / 2) + 8 * Math.cos(game.time.now / 200)

  # # Shake instructions text
  # instText.scale.setTo 2 + 0.1 * Math.sin(game.time.now / 100), 2 + 0.1 * Math.cos(game.time.now / 100)  if not gameStarted or gameOver

  # # Shake score text
  # scoreText.scale.setTo 2 + 0.1 * Math.cos(game.time.now / 100), 2 + 0.1 * Math.sin(game.time.now / 100)

  # # Update clouds timer
  # cloudsTimer.update()

  # # Remove offscreen clouds
  # clouds.forEachAlive (cloud) ->
  #   cloud.kill()  if cloud.x + cloud.width < game.world.bounds.left
  #   return


  # Scroll ground
  ground.tilePosition.x -= game.time.physicsElapsed * SPEED / 2  unless gameOver
  return

render = ->
  if DEBUG
    game.debug.renderSpriteBody bird
    tubes.forEachAlive (tube) ->
      game.debug.renderSpriteBody tube
      return

    invs.forEach (inv) ->
      game.debug.renderSpriteBody inv
      return

  return

state =
  preload: preload
  create: create
  update: update
  render: render

game = new Phaser.Game(0, 0, Phaser.CANVAS, parent, state, false, false)