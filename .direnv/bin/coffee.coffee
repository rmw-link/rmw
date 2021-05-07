coffee = require 'coffeescript'
{join} = require 'path'
klaw = require 'klaw'
fs = require 'fs/promises'

compile = (file)=>
  txt = await fs.readFile(file,"utf8")
  {js,v3SourceMap} = coffee.compile(txt,{bare:true, sourceMap:true})

  r = []

  importing = 0
  for line from js.split("\n")
    if line.startsWith("import ")
      importing = []

    if importing
      line = line.trim()
      if line[line.length-1] == ";"
        line = importing.join(' ')+line[...-1]
        line = line.replace(/'/g,'"')
        add = true
        for suffix from ['.js"','.ts"']
          if line.endsWith suffix
            add = false
            break
        if add
          line = line[...-1]+'.js"'
        r.push line
        importing = 0
      else
        importing.push line
    else
      r.push line

  [
    r.join "\n"
    v3SourceMap
  ]

compile2file = (file, out)=>
  [js,map] = await compile(file)
  fs.writeFile out, js
  fs.writeFile out+".map", map

compileDir = (indir, outdir)=>
  inlen = indir.length
  todo = []
  new Promise (resolve)=>
    klaw(indir)
      .on(
        'data'
        ({path})=>
          if not path.endsWith '.coffee'
            return
          js = join outdir, path[inlen...-7]+".js"
          todo.push compile2file(path, js)
      ).on(
        'end'
        =>
          await Promise.all(todo)
          resolve()
      )

do =>
  {argv} = process
  args = argv[2]
  if args == "--output"
    [outdir,indir] = argv[3..]
    pwd = process.cwd()
    outdir = join pwd, outdir
    indir = join pwd, indir
    await compileDir indir, outdir
  else
    console.log await compile args
  process.exit()
