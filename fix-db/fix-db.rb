#!/usr/bin/env ruby
require 'mongo'

client = Mongo::Client.new('mongodb://127.0.0.1:27017/ucome')
coll   = client[:rb_2016]
num = 23
cars = 40

while coll.find({gid: 1, status: 1}).first do
  ret = coll.update_one({gid: 1, status: 1},
                        {'$set' => {gid: num, robocar: num % cars}})
  num += 1
end

# fix bug.
coll.update_one({gid:40},{'$set'=>{robocar: 40}})
