# mnoe-admin-panel
Enterprise Admin Panel

```
 _____ _____ _____ _____     _____   _       _         _____             _
|     |   | |     |   __|___|  _  |_| |_____|_|___ ___|  _  |___ ___ ___| |
| | | | | | |  |  |   __|___|     | . |     | |   |___|   __| .'|   | -_| |
|_|_|_|_|___|_____|_____|   |__|__|___|_|_|_|_|_|_|   |__|  |__,|_|_|___|_|
```

[![Code Climate](https://codeclimate.com/github/maestrano/mnoe-admin-panel/badges/gpa.svg)](https://codeclimate.com/github/maestrano/mnoe-admin-panel)

# Maestrano Enterprise: Admin Panel

## How to run in development mode

### Prerequisite

Create and setup a Rails project to bootstrap an instance of Maestrano Enterprise Express as describe in the [mno-enterprise Github repository](https://github.com/maestrano/mno-enterprise).

Run this Maestrano Enterprise Express project, it should be available at http://localhost:7000.

This project will serve as a backend for our *mnoe-admin-panel* development environment.

### Install & run mno-enterprise-angular

* Clone this repository, and `cd mnoe-admin-panel`
* Run `npm install && bower install`
* To start the project, run `npm run serve`

A new browser tab should be open at address http://localhost:7001, with Browsersync enabled, waiting to auto-refresh in case template or CoffeeScript code is changed, or inject any modified styles.

## List of gulp tasks

* `npm run build` to build an optimized version of your application in `/dist`
* `npm run serve` to launch a browser sync server on your source files
* `npm run serve:dist` to launch a server on your optimized application
* `npm run test` to launch your unit tests with Karma
* `npm run test:auto` to launch your unit tests with Karma in watch mode
