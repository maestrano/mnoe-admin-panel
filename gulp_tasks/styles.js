const gulp = require('gulp');
const browserSync = require('browser-sync');
const sourcemaps = require('gulp-sourcemaps');
const less = require('gulp-less');
const postcss = require('gulp-postcss');
const autoprefixer = require('autoprefixer');
const inject = require('gulp-inject');
const wiredep = require('wiredep').stream;
var _ = require('lodash');

const conf = require('../conf/gulp.conf');

gulp.task('styles', styles);

function styles() {
  var lessOptions = {
    compress: false,
    options: [
      'bower_components',
      conf.path.src('/app')
    ]
  };

  var injectFiles = gulp.src([
    conf.path.src('/app/**/*.less'),
    conf.path.src('/fonts/**/*.less'),
    conf.path.src('/images/**/*.less'),
    `!${conf.path.src('/app/index.less')}`
  ], { read: false });

  var injectOptions = {
    transform: function(filePath) {
      filePath = filePath.replace(conf.paths.src + '/app/', '');
      return '@import "' + filePath + '";';
    },
    starttag: '// injector',
    endtag: '// endinjector',
    addRootSlash: false
  };

  return gulp.src(conf.path.src('app/index.less'))
    .pipe(inject(injectFiles, injectOptions))
    .pipe(wiredep(_.extend({}, conf.wiredep)))
    .pipe(sourcemaps.init())
    .pipe(less(lessOptions)).on('error', conf.errorHandler('Less'))
    .pipe(postcss([autoprefixer()])).on('error', conf.errorHandler('Autoprefixer'))
    .pipe(sourcemaps.write())
    .pipe(gulp.dest(conf.path.tmp()))
    .pipe(browserSync.stream());
}
