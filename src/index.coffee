#!/usr/bin/env coffee

# 参考资料: [UPNP自动端口映射的实现](https://blog.csdn.net/zfrong/article/details/3305738)

import {Xml,utf8Decode,utf8Encode} from './deps.js'
import local_ip from './local_ip.js'

M_SEARCH = utf8Encode """M-SEARCH * HTTP/1.1
HOST:239.255.255.250:1900
MAN:"ssdp:discover"
MX:3
ST:urn:schemas-upnp-org:device:InternetGatewayDevice:1""".replace(/\n/g, "\r\n")

class UpnpError extends Error
  constructor:($)->
    super($.faultstring+" "+$.errorCode+" : "+$.errorDescription)
    @$=$

Udp = =>

  udp = Deno.listenDatagram {
    port: 0
    transport: "udp"
    hostname: "0.0.0.0"
  }

  {addr} = udp
  {transport,hostname,port} = addr
  #console.log "#{transport}://#{hostname}:#{port}"
  udp


fetch_xml = (url, options={})=>
  Xml await (await fetch(url, options)).text()


class _SOAPAction
  constructor:(url, @serviceType)->
    @url = url
    @URL = new URL(url)
    @GetGenericPortMappingEntry = @_("GetGenericPortMappingEntry")
    @AddPortMapping = @_("AddPortMapping")

  mapPort:(protocol,internal,external,duration=0,description="")->
    {hostname, port} = @URL
    ip = await local_ip(
      hostname
      parseInt(port or 80)
    )
    @AddPortMapping """<NewRemoteHost></NewRemoteHost><NewExternalPort>#{external}</NewExternalPort><NewProtocol>#{protocol}</NewProtocol><NewInternalPort>#{internal}</NewInternalPort><NewInternalClient>#{ip}</NewInternalClient><NewEnabled>1</NewEnabled><NewPortMappingDescription>#{description}</NewPortMappingDescription><NewLeaseDuration>#{duration}</NewLeaseDuration>"""


  map:->
    li = []
    n = 0
    loop
      try
        r = await @GetGenericPortMappingEntry("<NewPortMappingIndex>#{n++}</NewPortMappingIndex>")
      catch err
        if err.$.errorCode == "713"
          break
        throw err

      r = Xml r
      r = r.dict [
        'NewPortMappingDescription'
        'NewProtocol'
        'NewInternalClient'
        'NewRemoteHost'
        'NewInternalPort'
        'NewExternalPort'
        'NewEnabled'
        'NewLeaseDuration'
      ]
      for i from [
        'NewInternalPort'
        'NewExternalPort'
        'NewEnabled'
        'NewLeaseDuration'
      ]
        r[i] = parseInt r[i]

      li.push r
    li

  _:(action)->
    {url, serviceType} = @
    response = "u:#{action}Response"
    headers = {
      "Content-Type": "text/xml"
      SOAPAction: "#{serviceType}##{action}"
    }
    body_begin = """<?xml version="1.0"?>
<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/" s:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/"><s:Body><u:#{action} xmlns:u="#{serviceType}">"""
    body_end = """</u:#{action}></s:Body></s:Envelope>"""

    (body)=>
      r = await fetch_xml(
        url
        {
          method:'POST'
          headers
          body: body_begin+body+body_end
        }
      )
      result = r.one(response)
      if result == undefined
        error = r.one("s:Fault")
        if error
          error = Xml(error).dict [
            "errorCode","errorDescription","faultstring","faultcode"
          ]
          throw new UpnpError(error)

      result


SOAPAction = ->
  new _SOAPAction(...arguments)

_control_url = (url)=>
  xml = await fetch_xml url

  URLBase = xml.one('URLBase')
  if not URLBase
    url = new URL(url)
    URLBase = url.origin

  for x from xml.li('service')
    x = Xml x

    serviceType = x.one('serviceType')
    #r = x.dict ['serviceId','serviceType','controlURL']
    if [
      "urn:schemas-upnp-org:service:WANIPConnection:1"
      "urn:schemas-upnp-org:service:WANPPPConnection:1"
    ].indexOf(serviceType) + 1
      controlURL = URLBase+x.one('controlURL')
      break

  if controlURL
    return SOAPAction(controlURL, serviceType)


export default =>
  udp = Udp()

  udp.send(
    M_SEARCH
    {
      hostname:"239.255.255.250"
      port:1900
      transport:"udp"
    }
  )

  [msg, remote] = await udp.receive(new Uint8Array(1472))

  msg = utf8Decode msg
  msg = msg.replace(/\r/g,'').split("\n")
  for i from msg
    if i.startsWith("LOCATION:")
      url = i.slice(9).trim()
      break

  if url
    return _control_url url

