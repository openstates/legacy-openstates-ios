#!/usr/bin/ruby

require 'rubygems'
require 'mongo'
require 'mysql'
require 'json'
include Mongo

if ARGV.count == 0
  puts "usage: ./mysql_shapefile_to_mongo.rb database"
  Process.exit
end

db = ARGV[0]

mo   = Connection.new.db('civicsets')
coll = mo.collection(db)
coll.remove()

my = Mysql::new("localhost", "root", "", db)
my.query("SET CHARSET UTF8");
res = my.query("SELECT * FROM DBF");
fields = res.fetch_fields

while r = res.fetch_row do
  row = {}
  fields.each_with_index do |f,i|
    row[f.name] = r[i]
  end
  
  row['bbox'] = [18000000.0, -18000000.0, 18000000.0, -18000000.0]
  
  row['shape'] = []
  res2 = my.query("SELECT x, y, part_id FROM shape_points WHERE dbf_id = #{r[0]} ORDER BY part_id, id");
  while vertex = res2.fetch_row do
    row['shape'][vertex[2].to_i-1] ||= []
    row['shape'][vertex[2].to_i-1] << [vertex[0].to_f, vertex[1].to_f]
    row['bbox'][0] = vertex[0].to_f if vertex[0].to_f < row['bbox'][0]
    row['bbox'][1] = vertex[0].to_f if vertex[0].to_f > row['bbox'][1]
    row['bbox'][2] = vertex[1].to_f if vertex[1].to_f < row['bbox'][2]
    row['bbox'][3] = vertex[1].to_f if vertex[1].to_f > row['bbox'][3]
  end
  if row['shape'][0].count == 1 && row['x'].nil? && row['y'].nil?
    row['x'] = row['shape'][0][0][0]
    row['y'] = row['shape'][0][0][1]
    row['shape'] = nil
    row['bbox'] = nil
  end
  res2.free

  coll.insert(row)
end
res.free