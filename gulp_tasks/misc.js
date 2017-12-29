const path = require('path');

const gulp = require('gulp');
const del = require('del');
const mainBowerFiles = require('main-bower-files');
const filter = require('gulp-filter');
const flatten = require('gulp-flatten');

const conf = require('../conf/gulp.conf');

gulp.task('clean', clean);
gulp.task('fonts', fonts);
gulp.task('images', images);
gulp.task('other', other);

function clean() {
  return del([conf.paths.dist, conf.paths.tmp]);
}

function fonts() {
  return gulp.src([
    'bower_components/font-awesome/fonts/*',
    'bower_components/bootstrap/fonts/*'
  ])
    .pipe(gulp.dest(conf.path.dist('/fonts/')));
}

function images() {
  return gulp.src(mainBowerFiles())
    .pipe(filter('**/*.{png,jpg,jpeg,gif}'))
    .pipe(flatten())
    .pipe(gulp.dest(conf.path.dist('/images/')));
}

function other() {
  const fileFilter = filter(file => file.stat.isFile());

  return gulp.src([
    path.join(conf.paths.src, '/**/*'),
    path.join(`!${conf.paths.src}`, '/**/*.{less,js,coffee,html}')
  ])
    .pipe(fileFilter)
    .pipe(gulp.dest(conf.paths.dist));
}
