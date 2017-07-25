const fs = require('fs');
const path = require('path');
const gulp = require('gulp');
const browserSync = require('browser-sync');
const wiredep = require('wiredep').stream;
const angularFilesort = require('gulp-angular-filesort');
const gulpInject = require('gulp-inject');

const bowerInfo = require('../bower.json');
const conf = require('../conf/gulp.conf');

gulp.task('inject', inject);
gulp.task('version', version);

// Scripts to run window.mnoe.version in the console
function version(done) {
  var func = '(function () {console.info("' + bowerInfo.description + ' - v' + bowerInfo.version + '"); window["mnoe"] = {"version": "' + bowerInfo.version + '"};}).call();';

  fs.writeFileSync(path.join(conf.paths.tmp, '/app', '/version.js'), func);

  done();
}

function inject() {
  const injectScripts = gulp.src([
    conf.path.tmp('app/**/*.module.js'),
    conf.path.tmp('app/**/*.js'),
    `!${conf.path.tmp('**/*.spec.js')}`
  ])//.pipe(angularFilesort()).on('error', conf.errorHandler('AngularFilesort'));

  const injectOptions = {
    ignorePath: [conf.paths.src, conf.paths.tmp],
    addRootSlash: false
  };

  return gulp.src(conf.path.src('index.html'))
    .pipe(gulpInject(injectScripts, injectOptions))
    .pipe(wiredep(Object.assign({}, conf.wiredep)))
    .pipe(gulp.dest(conf.paths.tmp))
    .pipe(browserSync.stream());
}
