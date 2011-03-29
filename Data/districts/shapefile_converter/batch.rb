#!/usr/bin/ruby

require 'rubygems'
require 'mysql'

=begin
urls = [
  'http://www.toronto.ca/open/datasets/address-points/addess_points_may2010_WGS84.zip', # WGS84
  #'http://www.toronto.ca/open/datasets/bikeways/Centreline_OD_WGS84.zip',               # WGS84
  'http://www.toronto.ca/open/datasets/bia/BIA_June2010_WGS84.zip',                     # WGS84
  'http://www.toronto.ca/open/datasets/centreline/centreline_may2010_WGS84.zip',        # WGS84
  'http://www.toronto.ca/open/datasets/foodbanks/food-banks.zip',                       # UTM 6 Degree Zone 17N NAD27
  'http://www.toronto.ca/open/datasets/interim-archaeological-potential/Archaeological_Potential_wgs84.zip', # WGS84
  'http://www.toronto.ca/open/datasets/interim-archaeological-potential/Water_wgs_84.zip',                   # WGS84
  'http://www.toronto.ca/open/datasets/neighbourhoods/neighbourhoods.zip',                              # UTM 6 Degree Zone 17N NAD27
  #'http://www.toronto.ca/open/datasets/one-way-streets/Centreline_OD_WGS84.zip',                       # WGS84
  'http://www.toronto.ca/open/datasets/parks/parks_may2010_WGS84.zip',                                  # WGS84
  'http://www.toronto.ca/open/datasets/police-locations/Toronto_Police_Facilities_WGS84.zip',           # WGS84
  'http://www.toronto.ca/open/datasets/priority-neighbourhoods/priority-invest-neighbourhoods.zip',     # UTM 6 Degree Zone 17N NAD27
  'http://www.toronto.ca/open/datasets/places-of-worship/places-of-worship.zip',                        # UTM 6 Degree Zone 17N NAD27
  'http://www.toronto.ca/open/datasets/solid-waste-management-districts/solid_waste_may2010_WGS84.zip', # WGS84
  'http://www.toronto.ca/open/datasets/traffic-signals-graphical/traffic_signals_may2010_WGS84.zip',    # WGS84
  'http://www.toronto.ca/open/datasets/transit-city/transit-city.zip',                                  # UTM 6 Degree Zone 17N NAD27
  'http://www.toronto.ca/open/datasets/turn-restrictions/turns_dataset_WGS84.zip',                      # WGS84
  'http://www.toronto.ca/open/datasets/wards/wards_may2010_wgs84.zip',                                  # WGS84
]

urls.each do |url|
  puts url
  system("wget #{url}")
end

Process.exit
=end

dbs = [
  'Priority_Investment_Neighbourhoods',
  'Toronto_Police_Facilities_WGS84',
  'Multi_level_crossing_WGS84',
  'Food_Banks_Meals_on_Wheels',
  'Food_Banks_Salvation_Army',
  'Food_Banks_Second_Harvest',
  'Turn_restrictions_WGS84',
  'V_TRAFFIC_SIGNALS_WGS84',
  'TO_CENTRELINE_WGS84',
  'ADDRESS_POINT_WGS84',
  'prov_ab_p_geo83_e',
  'Places_of_Worship',
  'can_ab_l_geo83_e',
  'can_ab_p_geo83_e',
  'FED_CA_1_0_0_ENG',
  'Neighbourhoods',
  'gcsd000a10a_e',
  'Transit_City',
  'icitw_wgs84',
  'ISWMD_WGS84',
  'UBIA_WGS84',
  'UPARK_WGS84',
]

=begin

dbs = [
  'Toronto_Police_Facilities_WGS84',
  'priority-invest-neighbourhoods',
  'Food_Banks_Meals_on_Wheels',
  'Food_Banks_Salvation_Army',
  'Food_Banks_Second_Harvest',
  'V_TRAFFIC_SIGNALS_WGS84',
  'ADDRESS_POINT_WGS84',
  'Places_of_Worship',
  'Neighbourhoods',
  'gcsd000a10a_e',
  'Transit_City',
  'ISWMD_WGS84',
  'icitw_wgs84',
  'UBIA_WGS84',
  'TCL3_UPARK',
]
=end

system("make")

my = Mysql::new("localhost", "root", "", "")
my.query("SET CHARSET UTF8");

dbs.each do |db|
  puts "#{db}\n"
  my.query("DROP DATABASE IF EXISTS `#{db}`")
  my.query("CREATE DATABASE `#{db}`")
  system("./shapefile_to_mysqldump civicsets/#{db}/#{db}")
  system("cat civicsets/#{db}/#{db}.sql | mysql -uroot #{db}")
  system("./mysql_shapefile_to_mongo.rb #{db}")
  #my.select_db(db)
  
end