###*
 * audioSprite.js example
###

'use strict'

type = if /Firefox/.test(navigator.userAgent) then '.ogg' else '.mp3'

player = new audioSprite(
	src: 'sprite' + type
	n: 1
	spriteLength: 1
	trimTime: 0.1
)

# Usage
player.play(1)
