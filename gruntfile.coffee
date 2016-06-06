gm = require('gm')
fs = require('fs')
mkdirp = require('mkdirp')
path = require('path')
imageMagick = gm.subClass({ imageMagick: true })

module.exports = (grunt) =>

    fromInto = (from, to) ->
        # return
        expand: true,
        cwd: from,
        src: "**/*",
        dest: to
        
    fromIntoWhat = (from, to, what) ->
        # return
        expand: true,
        cwd: from,
        src: what,
        dest: to

    grunt.initConfig(
        pkg: grunt.file.readJSON('package.json'),
        
        clean: ['build/**/*']
        
        resize:
            files:
                cwd:  'asset-src/resize/'
                dest: 'asset-src/resize/resized/'
                src: '*.png'
            settings:
                filter: "Point"
                resizeW: '200'
                resizeH: '200'
                mode: '%'
                    
        copy: 
            assets: fromIntoWhat('src/assets', 'build/assets', '**/*')
            images: fromIntoWhat('asset-src/ready-sprites/', 'build/assets', '**/*')
            html: fromIntoWhat('src', 'build', '*.html')
            css: fromIntoWhat('src', 'build', '*.css')
            phaser: fromIntoWhat('src', 'build', 'phaser.js')
                    
        browserify: 
            dev: 
                dest: 'build/game.js',
                src: ['src/scripts/**/*.js', 'src/scripts/**/*.coffee', 'src/scripts/*.coffee']
            
            build:
                dest: 'build/game.js',
                src: ['src/scripts/**/*.js', 'src/scripts/**/*.coffee'],
                options: 
                    keepAlive: false
                
            options: 
                watch: true,
                keepAlive: true,
                transform: ['coffeeify'],
                browserifyOptions: 
                    debug:true 				
    )


    grunt.loadNpmTasks('grunt-browserify');
    grunt.loadNpmTasks('grunt-contrib-copy');
    grunt.loadNpmTasks('grunt-contrib-clean');
    grunt.loadNpmTasks('grunt-gm');

    
    grunt.registerTask('resize', () ->
      done = this.async()
      processed = 0;
      cfg = grunt.config.get('resize')
      grunt.verbose.writeflags(cfg)
      files = grunt.file.expand({"cwd":cfg.files.cwd}, cfg.files.src)
      grunt.verbose.writeln(JSON.stringify(files))
      check = (e) =>
        if e 
            grunt.log.error(e)
            done(false)
        else  
            grunt.verbose.ok();
        processed++
        if processed >= files.length
            done(true);
            
      for file in files 
        if not fs.existsSync(cfg.files.cwd + file)
            grunt.log.error("Bad path "+cfg.files.cwd + file)
            done(false) 
        if not fs.existsSync(cfg.files.dest)
            grunt.verbose.writeln("making " + cfg.files.dest)
            mkdirp(cfg.files.dest);    
        dir = cfg.files.dest + path.dirname(file)    
        if not fs.existsSync(dir)
            grunt.verbose.writeln("making " + dir)
            mkdirp(dir);
        grunt.log.writeln("Resizing " + cfg.files.cwd + file + " to " + cfg.files.dest+file)
        imageMagick(cfg.files.cwd + file)
            .background('transparent')
            .filter(cfg.settings.filter)
            .resize(cfg.settings.resizeW,cfg.settings.resizeH, cfg.settings.mode)
            .write(cfg.files.dest+file, check);
        
    )
    
    grunt.registerTask('build', ['clean', 'browserify:build', 'copy']);
    grunt.registerTask('default', ['browserify:dev']);

