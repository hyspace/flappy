DEBUG = false
SPEED = 200
GRAVITY = 1400
FLAP = 350
SPAWN_RATE = 1 / 1000
OPENING = 120
SCALE = 1

HEIGHT = 512
WIDTH = 288
GAME_HEIGHT = 350
GROUND_HEIGHT = 112
GROUND_Y = HEIGHT - GROUND_HEIGHT

parent = document.querySelector("#screen")
gameStarted = undefined
gameOver = undefined

score = undefined
bg = undefined
credits = undefined
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
fallSnd = undefined
tubesTimer = undefined

floor = Math.floor


@main = ->
  spawntube = (openPos, flipped) ->
    tubeKey = if flipped then "tubeTop" else "tubeBottom"
    if flipped
      tubeY = floor(openPos - OPENING / 2 - 320)
    else
      tubeY = floor(openPos + OPENING / 2)
    tube = tubes.create(game.world.width, tubeY, tubeKey)
    tube.body.allowGravity = false

    # # Flip tube! *GASP*
    # tube.scale.setTo SCALE, (if flipped then -SCALE else SCALE)
    # tube.body.offset.y = (if flipped then -tube.body.height * SCALE else 0)

    # Move to the left
    tube.body.velocity.x = -SPEED
    tube

  spawntubes = ->
    tubeY = game.world.height / 2 + (Math.random()-0.5) * game.world.height * 0.2

    # Bottom tube
    bottube = spawntube(tubeY)

    # Top tube (flipped)
    toptube = spawntube(tubeY, true)

    # Add invisible thingy
    inv = invs.create(toptube.x + toptube.width / 2, 0)
    inv.width = 2
    inv.height = game.world.height
    inv.body.allowGravity = false
    inv.body.velocity.x = -SPEED
    return

  addScore = (_, inv) ->
    invs.remove inv
    score += 1
    scoreText.setText score
    scoreSnd.play()
    return

  setGameOver = ->
    gameOver = true
    bird.body.velocity.y = 100 if bird.body.velocity.y > 0
    bird.animations.stop()
    bird.frame = 1
    instText.setText "TOUCH\nTO TRY AGAIN"
    instText.renderable = true
    hiscore = window.localStorage.getItem("hiscore")
    hiscore = (if hiscore then hiscore else score)
    hiscore = (if score > parseInt(hiscore, 10) then score else hiscore)
    window.localStorage.setItem "hiscore", hiscore
    gameOverText.setText "GAMEOVER\n\nHIGH SCORE\n\n" + hiscore
    gameOverText.renderable = true

    # Stop all tubes
    tubes.forEachAlive (tube) ->
      tube.body.velocity.x = 0
      return

    invs.forEach (inv) ->
      inv.body.velocity.x = 0
      return


    # Stop spawning tubes
    game.time.events.remove(tubesTimer)

    # Make bird reset the game
    game.input.onTap.addOnce reset
    hurtSnd.play()
    fallSnd.play()
    return

  flap = ->
    start()  unless gameStarted
    unless gameOver
      # bird.body.velocity.y = -FLAP
      bird.body.gravity.y = 0;
      bird.body.velocity.y = -100;
      tween = game.add.tween(bird.body.velocity).to(y:-FLAP, 25, Phaser.Easing.Bounce.In,true);
      tween.onComplete.add ->
        bird.body.gravity.y = GRAVITY
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
        tubeTop: ["assets/tube1.png"]
        tubeBottom: ["assets/tube2.png"]
        ground: ["assets/ground.png"]

      audio:
        flap: ["assets/sfx_wing.mp3"]
        score: ["assets/sfx_point.mp3"]
        hurt: ["assets/sfx_hit.mp3"]
        fall:["assets/sfx_swooshing.mp3"]

    Object.keys(assets).forEach (type) ->
      Object.keys(assets[type]).forEach (id) ->
        game.load[type].apply game.load, [id].concat(assets[type][id])
        return

      return

    return

  create = ->

    # Set world dimensions
    game.world.width = WIDTH
    game.world.height = HEIGHT

    # Draw bg
    bg = game.add.graphics(0, 0)
    bg.beginFill 0xDDEEFF, 1
    bg.drawRect 0, 0, game.world.width, game.world.height
    bg.endFill()

    # Credits 'yo
    credits = game.add.text(game.world.width / 2, 10, "",
      font: "8px \"Press Start 2P\""
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
    bird.body.collideWorldBounds = true
    bird.body.setPolygon(
      24,1,
      34,16,
      30,32,
      20,24,
      12,34,
      2,12,
      14,2
    )

    # Add ground
    ground = game.add.tileSprite(0, GROUND_Y, WIDTH, GROUND_HEIGHT, "ground")
    ground.tileScale.setTo SCALE, SCALE

    # Add score text
    scoreText = game.add.text(game.world.width / 2, game.world.height / 4, "",
      font: "16px \"Press Start 2P\""
      fill: "#fff"
      stroke: "#430"
      strokeThickness: 4
      align: "center"
    )
    scoreText.anchor.setTo 0.5, 0.5

    # Add instructions text
    instText = game.add.text(game.world.width / 2, game.world.height - game.world.height / 4, "",
      font: "8px \"Press Start 2P\""
      fill: "#fff"
      stroke: "#430"
      strokeThickness: 4
      align: "center"
    )
    instText.anchor.setTo 0.5, 0.5

    # Add game over text
    gameOverText = game.add.text(game.world.width / 2, game.world.height / 2, "",
      font: "16px \"Press Start 2P\""
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
    fallSnd = game.add.audio("fall")

    # Add controls
    game.input.onDown.add flap

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
    bird.reset game.world.width * 0.3, game.world.height / 2
    bird.angle = 0
    bird.animations.play "fly"
    tubes.removeAll()
    invs.removeAll()
    return

  start = ->
    credits.renderable = false
    bird.body.allowGravity = true
    bird.body.gravity.y = GRAVITY

    # SPAWN tubeS!
    tubesTimer = game.time.events.loop 1 / SPAWN_RATE, spawntubes


    # Show score
    scoreText.setText score
    instText.renderable = false

    # START!
    gameStarted = true
    return

  update = ->
    if gameStarted
      if !gameOver
        # Make bird dive
        dvy = FLAP + bird.body.velocity.y
        bird.angle = (90 * dvy / FLAP) - 180
        bird.angle = -30  if bird.angle < -30
        if bird.angle > 80
          bird.angle = 90
          bird.animations.stop()
          bird.frame = 1
        else
          bird.animations.play()

        # Check game over
        game.physics.overlap bird, tubes, setGameOver
        setGameOver()  if not gameOver and bird.body.bottom >= GROUND_Y

        # Add score
        game.physics.overlap bird, invs, addScore

        # Remove offscreen tubes
        tubes.forEachAlive (tube) ->
          tube.kill() if tube.x + tube.width < game.world.bounds.left
          return
      else
        tween = game.add.tween(bird).to(angle: 90, 150, Phaser.Easing.Bounce.Out, true);
        if bird.body.bottom >= GROUND_Y + 3
          bird.y = GROUND_Y - 13
          bird.body.velocity.y = 0
          bird.body.allowGravity = false
          bird.body.gravity.y = 0

    else
      bird.y = (game.world.height / 2) + 8 * Math.cos(game.time.now / 200)
      bird.angle = 0


    # Scroll ground
    ground.tilePosition.x -= game.time.physicsElapsed * SPEED unless gameOver
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
  return

WebFontConfig =
  google:
    families: [ 'Press+Start+2P::latin' ]
  active: @main
(->
  wf = document.createElement('script')
  wf.src = (if 'https:' == document.location.protocol then 'https' else 'http') +
    '://ajax.googleapis.com/ajax/libs/webfont/1/webfont.js'
  wf.type = 'text/javascript'
  wf.async = 'true'
  s = document.getElementsByTagName('script')[0]
  s.parentNode.insertBefore(wf, s)
)()

scalex = window.innerWidth / WIDTH
scaley = window.innerHeight / GAME_HEIGHT
scale = Math.min(scalex, scaley)
wrapper = document.querySelector("#wrapper")
wrapper.style.height = scale * GAME_HEIGHT + 'px'
wrapper.style.width = scale * WIDTH + 'px'
parent.style.zoom = scale