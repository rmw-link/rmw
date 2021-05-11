export default (udp)=>
  console.log(
    await udp.send(
      new Uint8Array([])
      {
        hostname:"54.177.127.37"
        port:17944
        transport:"udp"
      }
    )
  )
  loop
    [msg, remote] = await udp.receive(
      new Uint8Array(1472)
    )
    console.log remote
    console.log msg
    console.log msg.length
    console.log ""
