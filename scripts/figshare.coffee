# Description:
#   Commands to query the Figshare API for open science data
#
# Dependencies:
#   figshare - https://github.com/karissa/figshare.js
#
# Commands:
#   hubot research on <subject> - Query for research datasets

logdev = require('tracer').colorConsole()
figshare = require('figshare')

module.exports = (robot) ->

	robot.respond /(research)( on)?(.*)/i, (res) ->
		query = res.match[res.match.length-1].trim()
		if query is ""
			res.reply "What are you looking for?"
			return

		data = { q: query }
		res.reply "Looking up open research data..."
		shown = total = 0
		# stream = figshare.search { fulltext: query }
		data = figshare.list(query)
		# stream.on 'data', (data, err) ->
		logdev.debug "#{data}"
		if data.items.count > 0
			datasets = data.items
			total += data.items.count
			shownhere = Math.min(datasets.length, 3)
			shown += shownhere
			latest = (
				"> #{getDsTitle(ds.title.replace('<p>', '').replace('</p>', ''))} - " +
				portalurl + "#{ds.article_id}" for ds in datasets
				)
			latest = latest[0..2].join '\n'
			if shownhere
				res.send "#{latest}"
		if shownhere < 3
			if not shown
				res.send "Far-fetched, Einstein! Nothing found on that topic - say *data request* for help."
		else if shown < total
			res.send "(#{shown} shown from #{total})"
