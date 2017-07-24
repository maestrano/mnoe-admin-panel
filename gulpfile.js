const gulp = require('gulp');
const HubRegistry = require('gulp-hub');
const browserSync = require('browser-sync');

const conf = require('./conf/gulp.conf');

// Load some files into the registry
const hub = new HubRegistry([conf.path.tasks('*.js')]);

// Tell gulp to use the tasks just loaded
gulp.registry(hub);

gulp.task('inject', gulp.series(gulp.parallel('styles', 'scripts'), 'version', 'inject'));
gulp.task('build', gulp.series('partials', gulp.parallel('inject', 'fonts', 'images', 'other'), 'build'));
gulp.task('test', gulp.series('scripts', 'karma:single-run'));
gulp.task('test:auto', gulp.series('watch', 'karma:auto-run'));
gulp.task('serve', gulp.series('inject', 'watch', 'browsersync'));
gulp.task('serve:dist', gulp.series('default', 'browsersync:dist'));
gulp.task('default', gulp.series('clean', 'build'));
gulp.task('watch', watch);

function reloadBrowserSync(cb) {
  browserSync.reload();
  cb();
}

function watch(done) {
  gulp.watch([
    conf.path.src('index.html'),
    'bower.json'
  ], gulp.parallel('inject'));

  gulp.watch(conf.path.src('app/**/*.html'), gulp.series('partials', reloadBrowserSync));
  gulp.watch([
    conf.path.src('**/*.less'),
    conf.path.src('**/*.css')
  ], gulp.series('styles'));
  gulp.watch([
    conf.path.src('**/*.js'),
    conf.path.src('**/*.coffee')
  ], gulp.series('inject'));

  // Watch 'mno-ui-elements'
  gulp.watch('bower_components/mno-ui-elements/dist/mno-ui-elements.js', gulp.series('inject'));
  gulp.watch('bower_components/mno-ui-elements/dist/mno-ui-elements.less', gulp.series('styles'));

  // Copy changed file in frontend to mno-enterprise-angular
  var override = gulp.watch(conf.path.customisation('/**/*'));
  override.on('change', function(path) {
    gulp.src(path, { 'base': conf.paths.customisation })
      .pipe(gulp.dest('./'));
  });

  done();
}
