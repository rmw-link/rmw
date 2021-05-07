export default local_ip = (hostname, port)=>
  # https://github.com/denoland/deno/issues/10519
  # Deno.connect not support transport:"udp"
  socket = await Deno.connect({
    port
    hostname
  })
  socket.close()
  return socket.localAddr.hostname


