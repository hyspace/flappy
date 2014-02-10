var DEBUG, FLAP, GAME_HEIGHT, GRAVITY, GROUND_HEIGHT, GROUND_Y, HEIGHT, OPENING, SCALE, SPAWN_RATE, SPEED, WIDTH, WebFontConfig, bg, bird, credits, deadInvs, deadTubeBottoms, deadTubeTops, fallSnd, flapSnd, floor, gameOver, gameOverText, gameStarted, ground, hurtSnd, instText, invs, main, parent, score, scoreSnd, scoreText, swooshSnd, tubes, tubesTimer;

DEBUG = false;

SPEED = 160;

GRAVITY = 1100;

FLAP = 320;

SPAWN_RATE = 1 / 1200;

OPENING = 100;

SCALE = 1;

HEIGHT = 384;

WIDTH = 288;

GAME_HEIGHT = 336;

GROUND_HEIGHT = 64;

GROUND_Y = HEIGHT - GROUND_HEIGHT;

parent = document.querySelector("#screen");

gameStarted = void 0;

gameOver = void 0;

deadTubeTops = [];

deadTubeBottoms = [];

deadInvs = [];

bg = null;

credits = null;

tubes = null;

invs = null;

bird = null;

ground = null;

score = null;

scoreText = null;

instText = null;

gameOverText = null;

flapSnd = null;

scoreSnd = null;

hurtSnd = null;

fallSnd = null;

swooshSnd = null;

tubesTimer = null;

floor = Math.floor;

main = function() {
  var addScore, create, flap, game, preload, render, reset, setGameOver, spawntube, spawntubes, start, state, update;
  spawntube = function(openPos, flipped) {
    var tube, tubeKey, tubeY;
    tube = null;
    tubeKey = flipped ? "tubeTop" : "tubeBottom";
    if (flipped) {
      tubeY = floor(openPos - OPENING / 2 - 320);
    } else {
      tubeY = floor(openPos + OPENING / 2);
    }
    if (deadTubeTops.length > 0 && tubeKey === "tubeTop") {
      tube = deadTubeTops.pop().revive();
      tube.reset(game.world.width, tubeY);
    } else if (deadTubeBottoms.length > 0 && tubeKey === "tubeBottom") {
      tube = deadTubeBottoms.pop().revive();
      tube.reset(game.world.width, tubeY);
    } else {
      tube = tubes.create(game.world.width, tubeY, tubeKey);
      tube.body.allowGravity = false;
    }
    tube.body.velocity.x = -SPEED;
    return tube;
  };
  spawntubes = function() {
    var bottube, inv, toptube, tubeY;
    tubes.forEachAlive(function(tube) {
      if (tube.x + tube.width < game.world.bounds.left) {
        if (tube.key === "tubeTop") {
          deadTubeTops.push(tube.kill());
        }
        if (tube.key === "tubeBottom") {
          deadTubeBottoms.push(tube.kill());
        }
      }
    });
    invs.forEachAlive(function(invs) {
      if (invs.x + invs.width < game.world.bounds.left) {
        deadInvs.push(invs.kill());
      }
    });
    tubeY = game.world.height / 2 + (Math.random() - 0.5) * game.world.height * 0.2;
    bottube = spawntube(tubeY);
    toptube = spawntube(tubeY, true);
    if (deadInvs.length > 0) {
      inv = deadInvs.pop().revive().reset(toptube.x + toptube.width / 2, 0);
    } else {
      inv = invs.create(toptube.x + toptube.width / 2, 0);
      inv.width = 2;
      inv.height = game.world.height;
      inv.body.allowGravity = false;
    }
    inv.body.velocity.x = -SPEED;
  };
  addScore = function(_, inv) {
    invs.remove(inv);
    score += 1;
    scoreText.setText(score);
    scoreSnd.play();
  };
  setGameOver = function() {
    var hiscore;
    gameOver = true;
    if (bird.body.velocity.y > 0) {
      bird.body.velocity.y = 100;
    }
    bird.animations.stop();
    bird.frame = 1;
    instText.setText("TOUCH\nTO TRY AGAIN");
    instText.renderable = true;
    hiscore = window.localStorage.getItem("hiscore");
    hiscore = (hiscore ? hiscore : score);
    hiscore = (score > parseInt(hiscore, 10) ? score : hiscore);
    window.localStorage.setItem("hiscore", hiscore);
    gameOverText.setText("GAMEOVER\n\nHIGH SCORE\n\n" + hiscore);
    gameOverText.renderable = true;
    tubes.forEachAlive(function(tube) {
      tube.body.velocity.x = 0;
    });
    invs.forEach(function(inv) {
      inv.body.velocity.x = 0;
    });
    game.time.events.remove(tubesTimer);
    game.time.events.add(1000, function() {
      return game.input.onTap.addOnce(function() {
        reset();
        return swooshSnd.play();
      });
    });
    hurtSnd.play();
  };
  flap = function() {
    var tween;
    if (!gameStarted) {
      start();
    }
    if (!gameOver) {
      bird.body.gravity.y = 0;
      bird.body.velocity.y = -100;
      tween = game.add.tween(bird.body.velocity).to({
        y: -FLAP
      }, 25, Phaser.Easing.Bounce.In, true);
      tween.onComplete.add(function() {
        return bird.body.gravity.y = GRAVITY;
      });
      flapSnd.play();
    }
  };
  preload = function() {
    var assets;
    assets = {
      spritesheet: {
        bird: ["assets/bird.png", 36, 26]
      },
      image: {
        tubeTop: ["assets/tube1.png"],
        tubeBottom: ["assets/tube2.png"],
        ground: ["assets/ground.png"],
        bg: ["assets/bg.png"]
      },
      audio: {
        flap: ["assets/sfx_wing.mp3"],
        score: ["assets/sfx_point.mp3"],
        hurt: ["assets/sfx_hit.mp3"],
        fall: ["assets/sfx_die.mp3"],
        swoosh: ["assets/sfx_swooshing.mp3"]
      }
    };
    Object.keys(assets).forEach(function(type) {
      Object.keys(assets[type]).forEach(function(id) {
        game.load[type].apply(game.load, [id].concat(assets[type][id]));
      });
    });
  };
  create = function() {
    console.log("%chttps://github.com/hyspace/flappy", "color: black; font-size: x-large");
    Phaser.Canvas.setSmoothingEnabled(game.context, false);
    game.stage.scaleMode = Phaser.StageScaleMode.SHOW_ALL;
    game.stage.scale.setScreenSize(true);
    game.world.width = WIDTH;
    game.world.height = HEIGHT;
    bg = game.add.tileSprite(0, 0, WIDTH, HEIGHT, 'bg');
    credits = game.add.text(game.world.width / 2, HEIGHT - GROUND_Y + 50, "", {
      font: "8px \"Press Start 2P\"",
      fill: "#fff",
      stroke: "#430",
      strokeThickness: 4,
      align: "center"
    });
    credits.anchor.x = 0.5;
    tubes = game.add.group();
    invs = game.add.group();
    bird = game.add.sprite(0, 0, "bird");
    bird.anchor.setTo(0.5, 0.5);
    bird.animations.add("fly", [0, 1, 2], 10, true);
    bird.body.collideWorldBounds = true;
    bird.body.setPolygon(24, 1, 34, 16, 30, 32, 20, 24, 12, 34, 2, 12, 14, 2);
    ground = game.add.tileSprite(0, GROUND_Y, WIDTH, GROUND_HEIGHT, "ground");
    ground.tileScale.setTo(SCALE, SCALE);
    scoreText = game.add.text(game.world.width / 2, game.world.height / 4, "", {
      font: "16px \"Press Start 2P\"",
      fill: "#fff",
      stroke: "#430",
      strokeThickness: 4,
      align: "center"
    });
    scoreText.anchor.setTo(0.5, 0.5);
    instText = game.add.text(game.world.width / 2, game.world.height - game.world.height / 4, "", {
      font: "8px \"Press Start 2P\"",
      fill: "#fff",
      stroke: "#430",
      strokeThickness: 4,
      align: "center"
    });
    instText.anchor.setTo(0.5, 0.5);
    gameOverText = game.add.text(game.world.width / 2, game.world.height / 2, "", {
      font: "16px \"Press Start 2P\"",
      fill: "#fff",
      stroke: "#430",
      strokeThickness: 4,
      align: "center"
    });
    gameOverText.anchor.setTo(0.5, 0.5);
    gameOverText.scale.setTo(SCALE, SCALE);
    flapSnd = game.add.audio("flap");
    scoreSnd = game.add.audio("score");
    hurtSnd = game.add.audio("hurt");
    fallSnd = game.add.audio("fall");
    swooshSnd = game.add.audio("swoosh");
    game.input.onDown.add(flap);
    reset();
  };
  reset = function() {
    gameStarted = false;
    gameOver = false;
    score = 0;
    credits.renderable = true;
    credits.setText("see console log\nfor github url");
    scoreText.setText("Flappy Bird");
    instText.setText("TOUCH TO FLAP\nbird WINGS");
    gameOverText.renderable = false;
    bird.body.allowGravity = false;
    bird.reset(game.world.width * 0.3, game.world.height / 2);
    bird.angle = 0;
    bird.animations.play("fly");
    tubes.removeAll();
    invs.removeAll();
  };
  start = function() {
    credits.renderable = false;
    bird.body.allowGravity = true;
    bird.body.gravity.y = GRAVITY;
    tubesTimer = game.time.events.loop(1 / SPAWN_RATE, spawntubes);
    scoreText.setText(score);
    instText.renderable = false;
    gameStarted = true;
  };
  update = function() {
    var tween;
    if (gameStarted) {
      if (!gameOver) {
        bird.angle = (90 * (FLAP + bird.body.velocity.y) / FLAP) - 180;
        if (bird.angle < -30) {
          bird.angle = -30;
        }
        if (bird.angle > 80) {
          bird.angle = 90;
          bird.animations.stop();
          bird.frame = 1;
        } else {
          bird.animations.play();
        }
        game.physics.overlap(bird, tubes, function() {
          setGameOver();
          return fallSnd.play();
        });
        if (!gameOver && bird.body.bottom >= GROUND_Y) {
          setGameOver();
        }
        game.physics.overlap(bird, invs, addScore);
      } else {
        tween = game.add.tween(bird).to({
          angle: 90
        }, 100, Phaser.Easing.Bounce.Out, true);
        if (bird.body.bottom >= GROUND_Y + 3) {
          bird.y = GROUND_Y - 13;
          bird.body.velocity.y = 0;
          bird.body.allowGravity = false;
          bird.body.gravity.y = 0;
        }
      }
    } else {
      bird.y = (game.world.height / 2) + 8 * Math.cos(game.time.now / 200);
      bird.angle = 0;
    }
    if (!gameOver) {
      ground.tilePosition.x -= game.time.physicsElapsed * SPEED;
    }
  };
  render = function() {
    if (DEBUG) {
      game.debug.renderSpriteBody(bird);
      tubes.forEachAlive(function(tube) {
        game.debug.renderSpriteBody(tube);
      });
      invs.forEach(function(inv) {
        game.debug.renderSpriteBody(inv);
      });
    }
  };
  state = {
    preload: preload,
    create: create,
    update: update,
    render: render
  };
  game = new Phaser.Game(WIDTH, HEIGHT, Phaser.CANVAS, parent, state, false, false);
};

WebFontConfig = {
  google: {
    families: ['Press+Start+2P::latin']
  },
  active: main
};

(function() {
  var s, wf;
  wf = document.createElement('script');
  wf.src = ('https:' === document.location.protocol ? 'https' : 'http') + '://ajax.googleapis.com/ajax/libs/webfont/1/webfont.js';
  wf.type = 'text/javascript';
  wf.async = 'true';
  s = document.getElementsByTagName('script')[0];
  return s.parentNode.insertBefore(wf, s);
})();
