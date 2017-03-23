var gulp = require('gulp');
var clean = require('gulp-clean');                  // очистка
var rename = require('gulp-rename');                // переименовывание файлов
var plumber = require('gulp-plumber');              // ищет ошибки              // !!!
var notify = require('gulp-notify');                // уведомленияёё

var minifyHtml = require('gulp-minify-html');       // сжимаем html
var rev = require('gulp-rev');
var revCollector = require('gulp-rev-collector');

var less = require('gulp-less');                    // less -> css
var prefix = require('gulp-autoprefixer');          // автопрефиксы для css
var minifyCss = require('gulp-minify-css');         // сжимаем css

var browserify = require('gulp-browserify');        // работа с nodejs
var coffeeify = require('coffeeify');               // coffee -> js
var uglify = require('gulp-uglify');                // сжимает js

var spritesmith = require('gulp.spritesmith');      // сборщик спрайтов
var imagemin = require('gulp-imagemin');            // сжатие картинок
var pngquant = require('imagemin-pngquant');        // сжатие картинок

var merge = require('merge-stream');                // ???
var buffer = require('vinyl-buffer');

var livereload = require('gulp-livereload');        // сервер
var connect = require('gulp-connect');              // подключение локального сервера

/*********/
/* LOCAL */
/*********/
gulp.task('default', ['clean'], function() {
  return gulp.run('watch')
});

gulp.task('clean', function() {
  return gulp.src('./dist', {read: false})
    .pipe(clean())
});

gulp.task('index', function() {
  return gulp.src('./app/*.html')
    .pipe(gulp.dest('./dist'))
    .pipe(connect.reload())
});

gulp.task('fonts', function() {
  return gulp.src('./app/fonts/*')
    .pipe(gulp.dest('./dist/fonts'))
});

gulp.task('sounds', function() {
  return gulp.src('./app/sounds/*')
    .pipe(gulp.dest('./dist/sounds'))
});

gulp.task('images', function() {
  return gulp.src('./app/images/*')
    .pipe(gulp.dest('./dist/images'))
});

gulp.task('style', function () {
  return gulp.src('./app/styles/index.less')
    .pipe(plumber({errorHandler: notify.onError("Error: <%= error.message %>")}))
    .pipe(less())
    .pipe(prefix("last 50 versions"))
    .pipe(rename('style.css'))
    .pipe(gulp.dest('./dist'))
    .pipe(connect.reload())
});

gulp.task('script', function() {
  return gulp.src('./app/**/index.coffee', { read: false })
    .pipe(plumber({errorHandler: notify.onError("Error: <%= error.message %>")}))
    .pipe(browserify({
      transform: ['coffeeify'],
      extensions: ['.coffee'],
      debug: true
    }))
    .pipe(rename('script.js'))
    .pipe(gulp.dest('./dist'))
    .pipe(connect.reload())
});

gulp.task('sprite', function() {
  var spriteData =
    gulp.src('./app/sprites/**/*.png') // путь, откуда берем картинки для спрайта
      .pipe(spritesmith({
        imgName: 'sprite.png',
        padding: 4,
        cssName: 'sprite.json',
        cssFormat: 'json',
        algorithm: 'binary-tree',
        cssTemplate: function(sprite) {
          var result = {};

          sprite.sprites.forEach(function (a) {
            delete a.px;
            delete a.source_image;
            delete a.total_width;
            delete a.total_height;
            delete a.offset_x;
            delete a.offset_y;
            delete a.escaped_image;

            name = a.name;
            delete a.name;
            result[name] = a;
          });

          return JSON.stringify(result);
        }
      }))

  spriteData.css.pipe(gulp.dest('./dist/sprites')); // путь, куда сохраняем стили
  spriteData.img.pipe(gulp.dest('./dist/sprites')); // путь, куда сохраняем картинку
});

gulp.task('connect', function() {
  connect.server({
    root: 'dist',
    https: true,
    livereload: true,
    port: 9000
  });
});

gulp.task('watch', ['connect', 'index', 'style', 'script', 'sprite', 'fonts', 'sounds', 'images'], function() {
  gulp.watch("./app/*.html"     , ['index'] );
  gulp.watch("./app/**/*.less"  , ['style'] );
  gulp.watch("./app/**/*.coffee", ['script'] );
  gulp.watch("./app/**/*.json"  , ['script'] );
  // gulp.watch("./app/sprites/*"   , ['sprite'] ); // TODO
});


/*****************/
/* DEPLOY - TEST */
/*****************/
gulp.task('deploy:test', ['cleanBefore:test'], function() {
  return gulp.run('cleanAfter:test')
});

gulp.task('dt', ['cleanBefore:test'], function() {
  return gulp.run('cleanAfter:test')
});

gulp.task('cleanBefore:test', function() {
  return gulp.src('/var/www/clickerTest', {read: false})
    .pipe(clean({ force:true }))
});

gulp.task('cleanAfter:test', ['rev:test'], function() {
  return gulp.src('./temp', {read: false})
    .pipe(clean())
});

gulp.task('fonts:test', function() {
  return gulp.src('./app/fonts/*')
  .pipe(gulp.dest('/var/www/clickerTest/fonts'), { force: true })
});

gulp.task('sounds:test', function() {
  return gulp.src('./app/sounds/*')
    .pipe(gulp.dest('/var/www/clickerTest/sounds'), { force: true })
});

gulp.task('images:test', function() {
  return gulp.src('./app/images/*')
    .pipe(gulp.dest('/var/www/clickerTest/images'), { force: true })
});

gulp.task('style:test', function () {
  return gulp.src('./app/styles/index.less')
    .pipe(less())
    .pipe(prefix("last 50 versions"))
    .pipe(minifyCss())
    .pipe(rename('style.css'))
    .pipe(rev())
    .pipe(gulp.dest('/var/www/clickerTest'), { force: true })
    .pipe(rev.manifest())
    .pipe(gulp.dest('./temp/manifests/css'))
});

gulp.task('script:test', function() {
  return gulp.src('./app/**/index.coffee', { read: false })
    .pipe(browserify({
      transform: ['coffeeify'],
      extensions: ['.coffee']
    }))
    // .pipe(uglify())
    .pipe(rename('script.js'))
    .pipe(rev())
    .pipe(gulp.dest('/var/www/clickerTest'), { force: true })
    .pipe(rev.manifest())
    .pipe(gulp.dest('./temp/manifests/js'))
});

gulp.task('sprite:test', function() {
  var spriteData =
    gulp.src('./app/sprites/**/*.png') // путь, откуда берем картинки для спрайта
      .pipe(spritesmith({
        imgName: 'sprite.png',
        padding: 4,
        cssName: 'sprite.json',
        cssFormat: 'json',
        algorithm: 'binary-tree',
        cssTemplate: function(sprite) {
          var result = {};

          sprite.sprites.forEach(function (a) {
            delete a.px;
            delete a.source_image;
            delete a.total_width;
            delete a.total_height;
            delete a.offset_x;
            delete a.offset_y;
            delete a.escaped_image;

            name = a.name;
            delete a.name;
            result[name] = a;
          });

          return JSON.stringify(result);
        }
      }))

  var imgStream = spriteData.img
    // .pipe(buffer())
    // .pipe(imagemin({
    //   progressive: true,
    //   svgoPlugins: [{removeViewBox: false}],
    //   use: [pngquant()]
    // }))
    .pipe(gulp.dest('/var/www/clickerTest/sprites'), { force: true }) // путь, куда сохраняем картинку

  var cssStream = spriteData.css
    .pipe(gulp.dest('/var/www/clickerTest/sprites'), { force: true }); // путь, куда сохраняем стили

  return merge(cssStream, imgStream);
});

gulp.task('rev:test', ['style:test', 'script:test', 'sprite:test', 'fonts:test', 'sounds:test', 'images:test'], function () {
  return gulp.src(['./temp/manifests/**/*.json', './app/*.html'])
    .pipe(revCollector({
      replaceReved: true
    }))
    .pipe(gulp.dest('/var/www/clickerTest'), { force: true })
});
