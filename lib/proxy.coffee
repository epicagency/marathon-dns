config = require '../config'
fs = require 'fs'
connect = require 'connect'
httpProxy = require 'http-proxy'
routingProxy = new httpProxy.RoutingProxy()


#
# The domain name -> server mappings are stored in ~/.marathon in JSON
# format. These *projects* consist of a `domain`: `port` mapping, where
# the domain is the URL to be captured, and the port is the port of the
# server running on localhost that should handle the incoming request.
#
if not fs.existsSync config.projectFile
  fs.writeFileSync config.projectFile, "{}"
projects = JSON.parse fs.readFileSync config.projectFile, 'utf-8'

# 
# Automatically reload the project file whenever it changes.
# 
fs.watch config.projectFile, ->
  console.log "regenerating project list"
  projects = JSON.parse fs.readFileSync config.projectFile, 'utf-8'

#
# Take a host value, and extract the domain given our TLD configuration.
# If no match is found for this domain, return false.
# 
findProject = (host) ->
  tlds = Object.keys(config.tlds).join('|')
  match = host.match(new RegExp("^(.+)\.#{tlds}"))
  if match? then { name: match[1], port: projects[match[1]] } else false

# 
# Take an inbound request, determine if there is a matching project for
# this domain. If so, proxy the request through to that server. If not,
# ignore this request (pass it through).
# 
proxy = (req, res, next) ->
  if { name, port } = findProject(req.headers['host'])
    buffer = httpProxy.buffer req
    routingProxy.proxyRequest req, res,
      host: 'localhost'
      port: port
      buffer: buffer
  else
    next()

#
# A simple connect server to handle our proxy
# 
app = connect()
 .use(proxy)
 .listen(config.proxyPort)
