import upnp from './index.js'

do =>
  soap = await upnp()
  if not soap
    console.log "UPNP not available"
    return

  # mapPort(protocol,internal,external,duration=0,description="")
  await soap.mapPort(
    "UDP",8080,8080,0,"upnp test"
  )
  console.log await soap.map()
