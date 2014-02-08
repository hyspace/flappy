gulp = require 'gulp'
coffee = require 'gulp-coffee'
gutil = require 'gulp-util'

gulp.task 'coffee', ->
  gulp.src ['index.coffee', '!gulpfile.coffee']
  .pipe coffee bare: true
  .on 'error', gutil.log
  .pipe gulp.dest '.'

gulp.task 'default', ['coffee']

gulp.watch '**/*.coffee', (ev)->
  gulp.run 'coffee'