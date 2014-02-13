gulp = require 'gulp'
coffee = require 'gulp-coffee'
gutil = require 'gulp-util'
connect = require 'gulp-connect'
concat = require 'gulp-concat'
uglify = require 'gulp-uglify'

gulp.task 'coffee', ->
  gulp.src ['index.coffee']
  .pipe coffee( bare: true ).on('error', gutil.log)
  .pipe gulp.dest 'tmp'

gulp.task 'concat', ->
  gulp.src ['bower_components/phaser/phaser.js', 'tmp/index.js']
  .pipe concat('index.min.js')
  .pipe uglify()
  .pipe gulp.dest '.'
  .pipe connect.reload()

gulp.task 'watch', ->
  gulp.watch ['index.coffee', '!gulpfile.coffee'], ['coffee']

gulp.task "connect", connect.server(
  root: __dirname
  port: 3000
  livereload: true
)

gulp.task 'default', ['coffee', 'concat', 'connect', 'watch']