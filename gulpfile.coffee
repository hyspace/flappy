gulp = require 'gulp'
coffee = require 'gulp-coffee'
gutil = require 'gulp-util'
connect = require 'gulp-connect'

gulp.task 'coffee', ->
  gulp.src ['index.coffee', '!gulpfile.coffee']
  .pipe coffee( bare: true ).on('error', gutil.log)
  .pipe gulp.dest '.'
  .pipe connect.reload()

gulp.task 'watch', ->
  gulp.watch ['index.coffee', '!gulpfile.coffee'], ['coffee']

gulp.task "connect", connect.server(
  root: __dirname
  port: 3000
  livereload: true
)

gulp.task 'default', ['coffee', 'connect', 'watch']