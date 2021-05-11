import {Upnp} from './deps.js'

export default (port, transport)=>

  upnp = await Upnp()
  if not upnp
    console.log "UPNP not available"
    return

  # mapPort(protocol,internal,external,duration=0,description="")
  ip = await upnp.mapPort(
    "UDP",port,port,0, "https://rmw.link"
  )
  for await {NewInternalClient,NewExternalPort,NewInternalPort,NewProtocol} from upnp.map()
    if NewProtocol.toLowerCase()!=transport
      continue
    if NewInternalClient!=ip
      continue
    if NewInternalPort == port
      console.log "upnp", NewExternalPort, "=>", port
      break
