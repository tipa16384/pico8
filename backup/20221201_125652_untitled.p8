pico-8 cartridge // http://www.pico-8.com
version 38
__lua__
snacks = "1000,2000,3000|4000|5000,6000|7000,8000,9000|10000"

data = {}

for line in split(snacks, "|") do 
  table.insert(data, table.concat(split(line, ","), 0, 0))
end

table.sort(data)

print("part 1: " .. data[#data])
print("part 2: " .. data[#data-2] + data[#data-1] + data[#data])

__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000