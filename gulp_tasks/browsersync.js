const gulp = require('gulp');
const browserSync = require('browser-sync');
const spa = require('browser-sync-spa');

const browserSyncConf = require('../conf/browsersync.conf');
const browserSyncDistConf = require('../conf/browsersync-dist.conf');

const proxyMiddleware = require('http-proxy-middleware');

browserSync.use(spa());

gulp.task('browsersync', browserSyncServe);
gulp.task('browsersync:dist', browserSyncDist);

// Rewrite /admin/xxx => /xxx after the proxy
var adminRewriteMiddleware = function (req, res, next) {
  req.url = req.url.replace(/^\/admin\//, "/");
  next();
};

const middleware = [
  proxyMiddleware('!/(admin|bower_components)/**', {target: 'http://localhost:7000'}),
  adminRewriteMiddleware
];

function browserSyncServe(done) {
  var conf = browserSyncConf();
  conf.server.middleware = middleware;

  browserSync.init(conf);
  done();
}

function browserSyncDist(done) {
  var conf = browserSyncDistConf();
  conf.server.middleware = middleware;
  browserSync.init(conf);
  done();
}
