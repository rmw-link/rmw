import {Upnp,cac} from './deps.js'

CLI = cac()
  .help()
  .version()
  .option(
    "--dir","profile dir"
  )


ARGS = CLI.parse()


export default =>
  udp = Deno.listenDatagram {
    port: 0
    transport: "udp"
    hostname: "0.0.0.0"
  }
  {addr} = udp
  {port} = addr

  console.log "listen on #{port}"

  queueMicrotask =>
    upnp = await Upnp()
    if not upnp
      console.log "UPNP not available"
      return

    # mapPort(protocol,internal,external,duration=0,description="")
    ip = await upnp.mapPort(
      "UDP",port,port,0,"upnp test"
    )
    for await {NewInternalClient,NewExternalPort,NewInternalPort,NewProtocol} from upnp.map()
      if NewProtocol!="UDP"
        continue
      if NewInternalClient!=ip
        continue
      if NewInternalPort == port
        console.log NewExternalPort
        break


