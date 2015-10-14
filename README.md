## fmi-to-sensor

Sends observations from [FMI Open data](https://en.ilmatieteenlaitos.fi/open-data) to
 [sensor-server](https://github.com/raimohanska/sensor-server).

## Installation

Clone this repository, then cd into it and

    npm install

## Configuration

Create file `config.coffee` like here:

```coffeescript
module.exports =
  place: "leppävaara"
  fmiApiKey: "your-fmi-api-key"
  mapping:
    "obs-obs-1-1-t2m": { location: "Tapiola", source: "fmi", type: "temperature"}
    "obs-obs-1-1-rh": { location: "Tapiola", source: "fmi", type: "humidity"}
  hoursBack: 20
  sensorServer: "http://192.168.1.2:5080/event"
```

## Running

Just do

    ./fmi2sensor

And there you go!

## Scheduling

Use cron! Add the following line to `/etc/crontab`.

    0  *    * * *   pi      cd /home/pi/fmi && ./fmi2sensor >> log.txt 2>&1

Make sure to replace the `/hom/pi/fmi` path with your local installation path.
