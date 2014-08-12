twitterAPI = require('node-twitter-api')
request = require('request')
exec = require('child_process').exec
path = require('path')
fs = require('fs')
_ = require('lodash')

tokens = require('tokens')

IMAGE_DIR = path.resolve './images'
TMP_FILE = path.resolve './tmp.png'

TWITTER_CONSUMER_KEY = process.env.CONSUMER_KEY || tokens.consumer_key
TWITTER_CONSUMER_SECERT = process.env.CONSUMER_SECRET || tokens.consumer_secret
TWITTER_ACCESS_TOKEN = process.env.ACCESS_TOKEN || tokens.access_token
TWITTER_ACCESS_SECRET = process.env.ACCESS_SECRET || tokens.access_secret


uploadProfileImage = (imagefile) ->

  twitter = new twitterAPI
    consumerKey: TWITTER_CONSUMER_KEY
    consumerSecret: TWITTER_CONSUMER_SECERT
    callback: ""

  twitter.updateProfileImage {image: imagefile}
  , TWITTER_ACCESS_TOKEN
  , TWITTER_ACCESS_SECRET
  , (error, response, result) ->
    console.log response

selectImage = () ->
  files = fs.readdirSync IMAGE_DIR
  num = _.random(0, files.length-1)
  return path.resolve IMAGE_DIR, files[num]

selectShell = (imagefile) ->
  shells = [
    () ->
      num = _.random(5, 10)
      "convert -noise #{num}x#{num} #{imagefile} #{imagefile}"
    () ->
      num = _.random(-90, 90)
      "convert -rotate #{num} #{imagefile} #{imagefile}"
    () ->
      num = _.random(1, 10)
      "convert -emboss #{num} #{imagefile} #{imagefile}"
    () ->
      num = _.random(1, 10)
      "convert -edge #{num} #{imagefile} #{imagefile}"
    () ->
      amplitude = _.random(10, 20)
      wavelength = _.random(10, 20)
      "convert -wave #{amplitude}x#{wavelength} #{imagefile} #{imagefile}"
    () ->
      num -> _.random(-200, 200)
      "convert -swirl #{num} #{imagefile} #{imagefile}"
  ]
  num = _.random(0, shells.length-1)
  return shells[num].call(this)


# main
selectedImagefile = selectImage()
console.log selectedImagefile # debug
exec "convert #{selectedImagefile} #{TMP_FILE}", (err, etdout, etderr) ->
  shell = selectShell TMP_FILE
  console.log shell #debug
  exec shell, (err, stdout, stderr) ->
    uploadProfileImage TMP_FILE
