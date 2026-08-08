#!/usr/bin/env ruby
# parity_all_zones.rb — full-tzdata differential gate for lssd/time-local.
# One process per binary: iterates EVERY zone on the system, switching ENV["TZ"]
# in-process (exercises the seed-cache invalidation path on every zone change),
# hashing all conversion results per zone. Compare per-zone digests across builds.
# Usage: ruby --disable-gems parity_all_zones.rb > digests.txt
require "digest"

ZONEROOT = ["/var/db/timezone/zoneinfo", "/usr/share/zoneinfo"].find { |d| File.directory?(d) }
zones = Dir.glob("**/*", base: ZONEROOT).select { |rel|
  path = File.join(ZONEROOT, rel)
  File.file?(path) && File.binread(path, 4) == "TZif"
}.sort

YEARS = [1915, 1938, 1949, 1968, 1975, 1982, 1994, 2007, 2011, 2016, 2021, 2026, 2033].freeze

zones.each do |zone|
  ENV["TZ"] = zone
  h = Digest::SHA256.new
  # dense civil grid: transition months surface because every hour of two days/month is covered
  YEARS.each do |y|
    (1..12).each do |m|
      [1, 15].each do |d|
        (0..23).each do |hr|
          t = Time.local(y, m, d, hr, 30, 33)
          h << "#{t.to_i},#{t.utc_offset},#{t.dst?},#{t.zone};"
        end
      end
    end
  end
  # seeded-random tuples incl. minute/second variation
  r = Random.new(zone.sum + 99)
  400.times do
    t = Time.local(1902 + r.rand(136), 1 + r.rand(12), 1 + r.rand(28), r.rand(24), r.rand(60), r.rand(60))
    h << "#{t.to_i},#{t.utc_offset},#{t.dst?},#{t.zone};"
  end
  # explicit-isdst old-style forms
  [true, false].each do |dst|
    t = Time.local(33, 30, 1, 1, 11, 2026, nil, nil, dst, nil)
    h << "x#{t.to_i},#{t.utc_offset};"
  end
  puts "#{zone} #{h.hexdigest}"
rescue => e
  puts "#{zone} ERR:#{e.class}"
end
$stderr.puts "zones=#{zones.size}"
