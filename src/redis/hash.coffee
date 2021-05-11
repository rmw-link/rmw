class Hash
  constructor:(@$key, @$)->

export default (key, redis)=>
  hash = new Hash(key, redis)
  new Proxy(
    hash
    get:(self, attr)=>
      if attr.charAt(0) == "$"
        return self[attr]

      self.$.hget self.$key, attr

    set:(self, attr, val)=>
      if attr.charAt(0) == "$"
        self[attr] = val
      else
        self.$.hset self.$key, attr, val
      return true

    deleteProperty:(self, attr)=>
      self.$.hdel self.$key, attr

    has:(self, attr)=>
      self.$.hexists self.$key, attr

    enumerate:(self)=>
      self.$.hgetall self.$key
  )
