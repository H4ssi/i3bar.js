
gulp = require 'gulp'
coffee = require 'gulp-coffee'
del = require 'del'

sources = ['**/*.coffee', '!gulpfile.coffee']

gulp.task 'scripts', ->
  gulp.src(sources)
    .pipe(coffee())
    .pipe(gulp.dest('.'))

gulp.task 'watch', ->
  gulp.watch(sources, ['scripts'])

gulp.task 'clean', ->
  del(['**/*.js'])

gulp.task 'default', ['watch', 'scripts']
