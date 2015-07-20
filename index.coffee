'use strict'
# through = require 'through2'
_ = require 'lodash'
fs = require 'fs.extra'

#Inspired by the awesome gulp-concat by wearefractal
#Check it out at https://github.com/wearefractal/gulp-concat

class CPlusPlusConcat
  @concat: (srcDirectory, destDirectory, callback=->) =>
    @getGroupedFiles srcDirectory, (error, groupedFiles)=>
      return callback error if error?
      console.log "#{JSON.stringify groupedFiles, null, 2}"

  @getGroupedFiles: (srcDirectory, callback=->) =>
    files = []
    fs.walk srcDirectory
      .on 'files', (root, fileStats, next) =>
        files = files.concat files, fileStats
        next()

      .on 'errors', (root, nodeStats, next) =>
        _.each nodeStats, (nodeStat) =>
          console.error "[ERROR] #{nodeStat.name}"
          console.error nodeStat.error.message || (nodeStat.error.code + ": " + nodeStat.error.path)

        next()

      .on 'end', =>
        callback null, @groupFiles files


  @groupFiles: (files) =>
    _.groupBy files, (file) =>
      return 'header' if _.endsWith(file.name, 'h') || _.endsWith(file.name, 'hpp')
      return 'source' if _.endsWith(file.name, 'c') || _.endsWith(file.name, 'cpp')
      return 'ignore'

module.exports = CPlusPlusConcat

  # bufferContents : (file, enc, cb) =>
  #   # ignore empty files
  #   if file.isNull()
  #     cb()
  #     return
  #   # we don't do streams (yet)
  #   if file.isStream()
  #     @emit 'error', new PluginError('gulp-concat', 'Streaming not supported')
  #     cb()
  #     return
  #   # enable sourcemap support for concat
  #   # if a sourcemap initialized file comes in
  #   if file.sourceMap and isUsingSourceMaps == false
  #     isUsingSourceMaps = true
  #   # set latest file if not already set,
  #   # or if the current file was modified more recently.
  #   if !latestMod or file.stat and file.stat.mtime > latestMod
  #     latestFile = file
  #     latestMod = file.stat and file.stat.mtime
  #   # construct concat instance
  #   if !concat
  #     concat = new Concat(isUsingSourceMaps, fileName, opt.newLine)
  #   # add file to concat instance
  #   concat.add file.relative, file.contents, file.sourceMap
  #   cb()
  #   return
  #
  # endStream = (cb) ->
  #   # no files passed in, no file goes out
  #   if !latestFile or !concat
  #     cb()
  #     return
  #   joinedFile = undefined
  #   # if file opt was a file path
  #   # clone everything from the latest file
  #   if typeof file == 'string'
  #     joinedFile = latestFile.clone(contents: false)
  #     joinedFile.path = path.join(latestFile.base, file)
  #   else
  #     joinedFile = new File(file)
  #   joinedFile.contents = concat.content
  #   if concat.sourceMapping
  #     joinedFile.sourceMap = JSON.parse(concat.sourceMap)
  #   @push joinedFile
  #   cb()
  #   return
  #
  # if !file
  #   throw new PluginError('gulp-concat', 'Missing file option for gulp-concat')
  # opt = opt or {}
  # # to preserve existing |undefined| behaviour and to introduce |newLine: ""| for binaries
  # if typeof opt.newLine != 'string'
  #   opt.newLine = gutil.linefeed
  # isUsingSourceMaps = false
  # latestFile = undefined
  # latestMod = undefined
  # fileName = undefined
  # concat = undefined
  # if typeof file == 'string'
  #   fileName = file
  # else if typeof file.path == 'string'
  #   fileName = path.basename(file.path)
  # else
  #   throw new PluginError('gulp-concat', 'Missing path in file options for gulp-concat')
  # through.obj bufferContents, endStream
