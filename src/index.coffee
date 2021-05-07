import {Upnp} from './deps.js'

do =>
  upnp = await Upnp()
  if not upnp
    console.log "UPNP not available"
    return

  # mapPort(protocol,internal,external,duration=0,description="")
  await upnp.mapPort(
    "UDP",8080,8080,0,"upnp test"
  )
  console.log await upnp.map()
