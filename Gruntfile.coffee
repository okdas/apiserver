module.exports= (grunt) ->
    grunt.initConfig
        pkg: grunt.file.readJSON 'package.json'
        clean:
            all: ['<%= pkg.config.compile.out %>/']

        coffee:
            main:
                options:
                    bare: true
                files: [
                    {
                        expand: true
                        cwd: '<%= pkg.config.compile.in %>'
                        src: ['**/*.coffee']
                        dest: '<%= pkg.config.compile.out %>'
                        ext: '.js'
                    }
                ]

        yaml:
            package:
                options:
                    ignored: /^_/
                    space: 2
                files: [
                    {
                        expand: true
                        cwd: '<%= pkg.config.compile.in %>'
                        src: ['**/*.yaml', '**/*.yml']
                        dest: '<%= pkg.config.compile.out %>/'
                        ext: '.json'
                    }
                ]

        copy:
            modules: 
                files: [
                    {
                        expand: true
                        cwd: '<%= pkg.config.compile.in %>'
                        src: ['**/*.py', '**/*.sh']
                        dest: '<%= pkg.config.compile.out %>'
                    }
                ]
            static:
                files: [
                    {
                        expand: true
                        cwd: '<%= pkg.config.compile.in %>/views'
                        src: ['**/*', '!**/*.coffee', '!**/*.md']
                        dest: '<%= pkg.config.compile.out %>/views'
                    }
                ]
            readme:
                {
                    src: '<%= pkg.config.compile.in %>/readme.md'
                    dest: '<%= pkg.config.compile.out %>/readme.md'
                }

        coffeelint:
            app:
                options:
                    indentation:
                        level: 'error'
                        value: 4
                    line_endings:
                        value: 'unix'
                        level: 'error'
                    max_line_length:
                        level: 'warn'
                files: [
                    {
                        src: '<%= pkg.config.compile.in %>/**/*.coffee'
                    }
                ]




    grunt.loadNpmTasks 'grunt-contrib-clean'
    grunt.loadNpmTasks 'grunt-contrib-copy'
    grunt.loadNpmTasks 'grunt-contrib-coffee'
    grunt.loadNpmTasks 'grunt-yaml'
    grunt.loadNpmTasks 'grunt-coffeelint'

    grunt.registerTask 'default', ['clean', 'yaml', 'coffee', 'copy']
    grunt.registerTask 'lint', ['coffeelint']