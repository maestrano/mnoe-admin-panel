const conf = require('./gulp.conf');

module.exports = function () {
  return {
    port: 7001,
    ui: {
      port: 7002
    },
    server: {
      baseDir: [
        conf.paths.tmp,
        conf.paths.src
      ],
      routes: {
        '/bower_components': 'bower_components'
      }
    },
    open: false
  };
};
