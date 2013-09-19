/**
 * audioSprite.js
 * @author Youhei Isokawa
 * @license MIT Lisence
*/


(function() {
  'use strict';
  var Player, Track, d, w;

  w = window;

  d = w.document;

  Track = function(src, spriteLength, trimTime) {
    var audio, force, kickoff, progress, track;
    track = this;
    audio = d.createElement('audio');
    audio.src = src;
    audio.autobuffer = true;
    audio.load();
    audio.muted = true;
    /*
    	This is the magic. Since we can't preload, and loading requires a user's 
    	input. So we bind a touch event to the body, and fingers crossed, the 
    	user taps. This means we can call play() and immediate pause - which will
    	start the download process - so it's effectively preloaded.
    	
    	This logic is pretty insane, but forces iOS devices to successfully 
    	skip an unload audio to a specific point in time.
    	first we play, when the play event fires we pause, allowing the asset
    	to be downloaded, once the progress event fires, we should have enough
    	to skip the currentTime head to a specific point.
    */

    force = function() {
      audio.pause();
      audio.removeEventListener('play', force, false);
    };
    progress = function() {
      audio.removeEventListener('progress', progress, false);
      if (track.updateCallback !== null) {
        track.updateCallback();
      }
    };
    audio.addEventListener('play', force, false);
    audio.addEventListener('progress', progress, false);
    kickoff = function() {
      audio.play();
      d.documentElement.removeEventListener('touchstart', kickoff, true);
    };
    d.documentElement.addEventListener('touchstart', kickoff, true);
    this.updateCallback = null;
    this.audio = audio;
    this.playing = false;
    this.lastUsed = 0;
    this.spriteLength = spriteLength;
    this.trimTime = trimTime;
    this.isFocus = true;
    window.addEventListener('focus', function(e) {
      return track.isFocus = true;
    }, false);
    window.addEventListener('blur', function(e) {
      return track.pause();
    }, false);
    window.addEventListener('pageshow', function(e) {
      return track.isFocus = true;
    }, false);
    window.addEventListener('pagehide', function(e) {
      return track.pause();
    }, false);
  };

  Track.prototype.play = function(position) {
    var audio, e, length, nextTime, time, track;
    track = this;
    audio = this.audio;
    length = this.spriteLength;
    time = position * length;
    nextTime = time + length - this.trimTime;
    clearInterval(track.timer);
    track.playing = true;
    track.lastUsed = +new Date();
    audio.muted = false;
    audio.pause();
    try {
      if (time === 0) {
        time = 0.01;
      }
      audio.currentTime = time;
      audio.play();
    } catch (_error) {
      e = _error;
      this.updateCallback = function() {
        track.updateCallback = null;
        audio.currentTime = time;
        return audio.play();
      };
      audio.play();
    }
    track.timer = setInterval(function() {
      if (audio.currentTime >= nextTime || !track.isFocus) {
        track.pause();
      }
    }, 10);
  };

  Track.prototype.pause = function() {
    var audio, track;
    track = this;
    audio = this.audio;
    audio.pause();
    audio.muted = true;
    clearInterval(track.timer);
    track.playing = false;
  };

  /**
   * Audio Sprite Player
   * @param {Object} option src, n, spriteLength, trimTime
   *
   * Usage:
   * var player = new audioSprite({
   *   src: 'path/audio.mp3',
   *   spriteLength: 1,
   *   trimTime: 0.1
   * });
   *
   * player.play(1);
  */


  Player = function(option) {
    var n, total, tracks;
    tracks = [];
    n = option.n;
    total = option.n;
    while (n--) {
      tracks.push(new Track(option.src, option.spriteLength, option.trimTime));
    }
    return {
      tracks: tracks,
      play: function(position) {
        var i, track;
        if (isNaN(position) || position === null || position === 'undefined') {
          return;
        }
        i = total;
        track = null;
        while (i--) {
          if (tracks[i].playing === false) {
            track = tracks[i];
            break;
          } else if (track === null || tracks[i].lastUsed < track.lastUsed) {
            track = tracks[i];
          }
        }
        if (track) {
          return track.play(position - 1);
        } else {

        }
      }
    };
  };

  w.audioSprite = Player;

}).call(this);
