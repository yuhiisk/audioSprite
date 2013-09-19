###*
 * audioSprite.js
 * @author Youhei Isokawa
 * @license MIT Lisence
###

'use strict'

w = window
d = w.document

Track = (src, spriteLength, trimTime) ->
	track = this
	audio = d.createElement('audio')

	audio.src = src
	audio.autobuffer = true
	audio.load()
	audio.muted = true # makes no difference on iOS :(
	
	###
	This is the magic. Since we can't preload, and loading requires a user's 
	input. So we bind a touch event to the body, and fingers crossed, the 
	user taps. This means we can call play() and immediate pause - which will
	start the download process - so it's effectively preloaded.
	
	This logic is pretty insane, but forces iOS devices to successfully 
	skip an unload audio to a specific point in time.
	first we play, when the play event fires we pause, allowing the asset
	to be downloaded, once the progress event fires, we should have enough
	to skip the currentTime head to a specific point. 
	###
		
	force = ->
		audio.pause()
		audio.removeEventListener('play', force, false)
		return
	
	progress = ->
		audio.removeEventListener('progress', progress, false)
		if track.updateCallback isnt null then track.updateCallback()
		return

	
	audio.addEventListener('play', force, false);
	audio.addEventListener('progress', progress, false);
	
	kickoff = ->
		audio.play()
		d.documentElement.removeEventListener('touchstart', kickoff, true)
		return
	
	d.documentElement.addEventListener('touchstart', kickoff, true)

	this.updateCallback = null
	this.audio = audio
	this.playing = false
	this.lastUsed = 0
	this.spriteLength = spriteLength
	this.trimTime = trimTime

	# forced stop audio
	this.isFocus = true
	window.addEventListener('focus', (e) ->
		track.isFocus = true
	, false)
	window.addEventListener('blur', (e) ->
		track.pause()
	, false)
	window.addEventListener('pageshow', (e) ->
		track.isFocus = true
	, false)
	window.addEventListener('pagehide', (e) ->
		track.pause()
	, false)
	return


Track::play = (position) ->
	track = this
	audio = this.audio
	length = this.spriteLength
	time = position * length
	nextTime = time + length - this.trimTime
		
	# console.log('position: ' + position, 'time: ' + time, 'nextTime: ' + nextTime)
	clearInterval(track.timer)
	track.playing = true
	track.lastUsed = +new Date()
	
	audio.muted = false
	audio.pause()
	try
		if time is 0 then time = 0.01 # yay hacks. Sometimes setting time to 0 doesn't play back
		audio.currentTime = time
		audio.play()

	catch e
		this.updateCallback = ->
			track.updateCallback = null
			audio.currentTime = time
			audio.play()

		audio.play()
	

	track.timer = setInterval( ->
		if audio.currentTime >= nextTime or not track.isFocus
			track.pause()
			return
	, 10)
	return

Track::pause = ->
	track = this
	audio = this.audio

	audio.pause()
	audio.muted = true
	clearInterval(track.timer)
	track.playing = false
	return


###*
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
###
Player = (option) ->
	tracks = []
	n = option.n
	total = option.n

	while n--
		tracks.push(new Track(option.src, option.spriteLength, option.trimTime))

	tracks: tracks
	play: (position) ->
		if isNaN(position) or position is null or position is 'undefined' then return

		i = total
		track = null
			
		while i--
			if tracks[i].playing is false
				track = tracks[i]
				break
			else if track is null or tracks[i].lastUsed < track.lastUsed
				track = tracks[i]
		
		if track
			track.play(position - 1)
		else
			# console.log('could not find a track to play :(');

# export to global
w.audioSprite = Player
