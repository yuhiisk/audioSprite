module.exports = (grunt) ->
	'use strict'

	grunt.initConfig
		pkg: grunt.file.readJSON 'package.json'
		coffee:
			complile:
				files: [
					expand: true
					cwd: 'coffee/'
					src: ['**/*.coffee']
					dest: 'js/'
					ext: '.js'
				]
		connect:
			server:
				options:
					port: 8000
					base: '.'
		#concat:
		#	dist:
		#		src: []
		#		dest: ''

		watch:
			files: ['coffee/*.coffee']
			tasks: 'coffee'
			options:
				livereload: true
				title: 'Grunt watch'
				message: 'Compiled!\\nｷﾀ━ヽ(*´Д｀*)ﾉ━ｯ!!!!'

	grunt.loadNpmTasks 'grunt-contrib-coffee'
	grunt.loadNpmTasks 'grunt-contrib-connect'
	# grunt.loadNpmTasks 'grunt-contrib-concat'
	grunt.loadNpmTasks 'grunt-contrib-watch'

	grunt.registerTask 'default', ['coffee', 'connect', 'watch']
	return
