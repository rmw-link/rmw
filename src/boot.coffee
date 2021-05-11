import {mcron} from './deps.js'
import upnp from './upnp.js'
import Udp from './udp.js'
import config from './config.js'

export default (redis)=>
  config.$ = redis

  transport = "udp"
  hostname = "0.0.0.0"

  listen = (port)=>
    udp = Deno.listenDatagram {
      port
      transport
      hostname
    }
    Udp udp
    udp

  port = (await config.port)
  if port
    port = parseInt(port)
    udp = listen port
  else

    try
      udp = listen parseInt(Math.random()*10000)+8081
    catch err
      if err.name != "AddrInUse"
        throw err

      udp = listen(0)

    config.port = port = udp.addr.port

  console.log "listening #{transport}://#{hostname}:"+port
  mcron(
    upnp.bind(upnp, port, transport)
    14
  )
