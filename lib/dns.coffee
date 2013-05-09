dnsserver = require 'dnsserver'
config = require '../config'

NS_T_A = 1
NS_C_IN = 1
NS_RCODE_NXDOMAIN = 3

class DNSServer extends dnsserver.Server

  constructor: ->
    super
    @on 'request', @handleRequest

  listen: (port, callback) ->
    @bind port
    callback?()

  handleRequest: (req, res) =>

    q = req.question ? {}

    match = false
    if q.type is NS_T_A and q['class'] is NS_C_IN
      for tld, ip of config.tlds
        pattern = new RegExp(tld)
        if pattern.test q.name
          res.addRR q.name, NS_T_A, NS_C_IN, 600, ip
          match = true
    res.header.rcode = NS_RCODE_NXDOMAIN unless match

    res.send()


dnsserver = (new DNSServer()).listen config.dnsPort
