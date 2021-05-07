# extract

util for extract text

## import

```
import { xml } from 'https://deno.land/x/extract@0.1.34/mod.js'
```

or export in your `deps.js`

```
export { xml } from 'https://deno.land/x/extract@0.1.34/mod.js'
```

## use

see [src/index_test.coffee](./src/index_test.coffee) or [lib/index_test.js](./lib/index_test.js)  for example

coffeescript version

```coffee
#include ./src/index_test.coffee
```

```

javascript version

```javascript
#include ./lib/index_test.js
```

output like below

```json
[
  {
    NewPortMappingDescription: "upnp test",
    NewProtocol: "UDP",
    NewInternalClient: "172.16.0.15",
    NewRemoteHost: "",
    NewInternalPort: 8080,
    NewExternalPort: 8080,
    NewEnabled: 1,
    NewLeaseDuration: 0
  }
]
```
