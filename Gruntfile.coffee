module.exports= (grunt) ->
    grunt.initConfig
        pkg: grunt.file.readJSON 'package.json'

        #clean:
        #    all: ['<%= pkg.config.build.app.node %>/']

        coffee:
            main:
                options:
                    bare: true
                files: [{
                    expand: true
                    cwd: '<%= pkg.config.build.src.root %>'
                    src: ['**/*.coffee']
                    dest: '<%= pkg.config.build.app.root %>'
                    ext: '.js'
                }]

        yaml:
            package:
                options:
                    ignored: /^_/
                    space: 2
                files: [
                    {
                        expand: true
                        cwd: '<%= pkg.config.build.src.root %>'
                        src: ['**/*.yaml', '**/*.yml', '!**/views/**']
                        dest: '<%= pkg.config.build.app.root %>/'
                        ext: '.json'
                    }
                ]

        jade:
            compile:
                options:
                    data:
                        debug: false
                files: [{
                    expand: true
                    cwd: '<%= pkg.config.build.src.node %>/views/templates'
                    src: ['**/*.jade']
                    dest: '<%= pkg.config.build.app.node %>/views/templates'
                    ext: '.html'
                }]

        less:
            compile:
                files: [{
                    expand: true
                    cwd: '<%= pkg.config.build.src.node %>/views/assets/styles'
                    src: ['**/*.less']
                    dest: '<%= pkg.config.build.app.node %>/views/assets/styles'
                    ext: '.css'
                }]

        copy:
            views:
                files: [{
                    expand: true
                    cwd: '<%= pkg.config.build.src.node %>/views/assets'
                    src: ['**/*', '!**/components/**', '!**/*.less', '!**/*.jade', '!**/*.coffee', '!**/*.md']
                    dest: '<%= pkg.config.build.app.node %>/views/assets'
                }, {
                    expand: true
                    cwd: '<%= pkg.config.build.src.node %>/views/assets/components/font-awesome/font'
                    src: ['**/*']
                    dest: '<%= pkg.config.build.app.node %>/views/assets/fonts/awesome'
                }]

        #coffeelint:
        #    app:
        #        options:
        #            indentation:
        #                level: 'error'
        #                value: 4
        #            line_endings:
        #                value: 'unix'
        #                level: 'error'
        #            max_line_length:
        #                level: 'warn'
        #        files: [
        #            {
        #                src: '<%= pkg.config.build.src.root %>/**/*.coffee'
        #            }
        #        ]

        docco:
            debug:
                src: ['**/*.coffee'],
                options:
                    output: 'spec/docs/'




    grunt.loadNpmTasks 'grunt-contrib-clean'
    grunt.loadNpmTasks 'grunt-contrib-copy'
    grunt.loadNpmTasks 'grunt-contrib-coffee'
    grunt.loadNpmTasks 'grunt-contrib-jade'
    grunt.loadNpmTasks 'grunt-contrib-less'
    grunt.loadNpmTasks 'grunt-yaml'
    #grunt.loadNpmTasks 'grunt-coffeelint'
    grunt.loadNpmTasks 'grunt-docco'

    grunt.registerTask 'default', ['yaml', 'coffee', 'jade', 'less', 'copy']
    #grunt.registerTask 'lint', ['coffeelint']
    grunt.registerTask 'doc', ['docco']
