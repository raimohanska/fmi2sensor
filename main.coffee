_ = require('lodash')
request = require('request-promise')
Url = require('url')
Promise = require("bluebird")
Keen = require "keen.io"
parseXml = Promise.promisify(require('xml2js').parseString)
processors = require('xml2js/lib/processors')
inspect = require("util").inspect

{fmiApiKey, place, mapping, hoursBack, keenConfig} = require('./config.coffee')

keenClient = Keen.configure keenConfig
log = (x) -> console.log(inspect(x, true, 10))
formatDateFmi = (d) -> d.toISOString().substring(0, 19) + "Z"

endTime = new Date()
startTime = new Date(endTime.getTime() - (hoursBack * 3600000))

url = Url.parse('http://data.fmi.fi/fmi-apikey/' + fmiApiKey + '/wfs')

url.query = {
  request:"getFeature"
  storedquery_id: "fmi::observations::weather::timevaluepair"
  place
  timestep: 60
  starttime: formatDateFmi(startTime)
}

request(Url.format(url))
.then((resultXml) ->
    parseXml(resultXml, {tagNameProcessors: [processors.stripPrefix, processors.firstCharLowerCase], mergeAttrs: true})
)
.then((result) ->
  result.featureCollection.member.map (member) ->
    series = member.pointTimeSeriesObservation[0].result[0].measurementTimeseries[0]
    {
      id: series["gml:id"][0],
      data: series.point
        .map((point) -> {time: point.measurementTVP[0].time[0], value: point.measurementTVP[0].value[0]})
        .filter((point) -> !isNaN(point. value))
    }
)
.then((result) ->
  for key, value of mapping
    observation = _.find(result, { id: key })
    if observation?
      observation.data.forEach (event) ->
        keenEvent = _.assign({value: parseFloat(event.value), keen: { timestamp: event.time }}, value)
        console.log keenEvent
        keenClient.addEvent "fmi", keenEvent, (err, res) ->
          if err
            console.log "Keen error:  " + err
)
