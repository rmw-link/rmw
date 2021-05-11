import {Redis,equal,nanoid,exists,parseURL,pathJoin,ensureDir,cac,homedir,tomlLoad,tomlDump} from './deps.js'
import version from './version.js'
import boot from './boot.js'



export default =>
  CLI = cac('rmw')
    .help()
    .version(version)
    .option(
      "--dir [dir]","profile dir"
    )

  {options} = CLI.parse()

  {v,help,dir} = options

  if v or help
    return

  if not dir
    dir = pathJoin homedir(),".rmw"

  await ensureDir dir

  config_path = pathJoin dir, "config.toml"
  if await exists(config_path)
    config = tomlLoad await Deno.readTextFile(config_path)
  else
    config = {}

  {tendis} = config

  if not tendis
    change = true
    password = nanoid()
    config.tendis = tendis = "redis://default:#{password}@127.0.0.1:51002/1"

  if change
    await Deno.writeTextFile(
      config_path
      tomlDump config
    )


  boot(
    await Redis(parseURL tendis)
  )




