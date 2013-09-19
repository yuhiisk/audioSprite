/**
 * audioSprite.js example
*/


(function() {
  'use strict';
  var player, type;

  type = /Firefox/.test(navigator.userAgent) ? '.ogg' : '.mp3';

  player = new audioSprite({
    src: 'sprite' + type,
    n: 1,
    spriteLength: 1,
    trimTime: 0.1
  });

  player.play(1);

}).call(this);
