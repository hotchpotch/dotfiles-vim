#!/usr/bin/env ruby

d = Dir.glob('.*').reject{|n| n =~ %r!/((\.git)|(\.svn)|(\.{1,2}))$! }
d.each do |f|
  file = Dir.pwd + '/' + f
  `ln -s #{file} ~/`
end
