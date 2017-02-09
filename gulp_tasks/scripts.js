const gulp = require('gulp');
const coffee = require('gulp-coffee');
const coffeelint = require('gulp-coffeelint');
const ngAnnotate = require('gulp-ng-annotate');

const conf = require('../conf/gulp.conf');

gulp.task('scripts', scripts);

function scripts() {
  return gulp.src(conf.path.src('**/*.coffee'))
    .pipe(coffeelint())
    .pipe(coffeelint.reporter())
    .pipe(coffee())
    .pipe(ngAnnotate())

    .pipe(gulp.dest(conf.path.tmp()));
}
