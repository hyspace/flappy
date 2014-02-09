gulp = require 'gulp'
coffee = require 'gulp-coffee'
gutil = require 'gulp-util'
connect = require("gulp-connect")

gulp.task 'coffee', ->
  gulp.src ['index.coffee', '!gulpfile.coffee']
  .pipe coffee bare: true
  .on 'error', gutil.log
  .pipe gulp.dest '.'
  .pipe connect.reload()

gulp.task "connect", connect.server(
  root: __dirname
  port: 3000
  livereload: true
  open:
    browser: "Google Chrome" # if not working OS X browser: 'Google Chrome'
)

gulp.task 'default', ['coffee', 'connect']

gulp.watch '**/*.coffee', (ev)->
  gulp.run 'coffee'