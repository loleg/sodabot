# Description:
#   A module for IoT
#
# Dependencies:
#   "lodash.js"
#   "moment.js"
#
# Commands:
#   hubot demotime - Connect to a data source

moment = require 'moment'
_ = require 'lodash'
fs = require 'fs'

logdev = require('tracer').colorConsole()
logger = require('tracer').dailyfile(
  root: '.'
  maxLogFiles: 5)

ONIA_REMOTE_URL = process.env.ONIA_REMOTE_URL or ''
ONIA_REMOTE_KEY = process.env.ONIA_REMOTE_KEY or ''

timeSince = (last_ping) ->
  fmt = "ddd, D MMM YYYY hh:mm:ss"
  ping_at = moment(last_ping, fmt)
  time_since = moment() - end_at
  return time_since.fromNow()

if ONIA_REMOTE_URL
  module.exports = (robot) ->

    # A per-channel brain
    getChannel = (id) ->
      return robot.brain.get("onia-#{id}") or {
          id: id,
          hasInvited: false,
          hasDemoed: false,
        }
    saveChannel = (dt) ->
      id = dt.id
      robot.brain.set "onia-#{id}", dt
    helloChannel = (id) ->
      chdata = getChannel id
      chdata.hasInvited = true
      saveChannel chdata
      return chdata

    deviceInfo = null
    currentStatus = null
    theInterval = null
    refreshStatus = (res) ->
      logdev.info ONIA_REMOTE_URL
      robot.http(ONIA_REMOTE_URL)
        .headers({
          'Accept': 'application/json',
          'Authorization': ONIA_REMOTE_KEY
        })
        .get() (err, response, body) ->
          # error checking code here
          # logdev.info body
          jsondata = JSON.parse body
          deviceInfo = if jsondata then jsondata[jsondata.length-1]
          if _.isEmpty(deviceInfo)
            return logdev.warn "Could not connect to server #{ONIA_REMOTE_URL}"
          newStatus = deviceInfo['digital_in_3']
          logdev.info "Obtained status #{newStatus}"
          if currentStatus == null
            currentStatus = newStatus
          if newStatus != currentStatus
            res.send "Somone has Pushed the Button! :red_circle:"
            clearInterval(theInterval)

    # Notify by developer that something is starting
    robot.respond /demotime.*/, (res) ->
      chdata = helloChannel res.message.room
      res.send "Okay! I will now listen to the devices."
      theInterval = setInterval () ->
        refreshStatus(res)
      , 1000 * 5
