require 'bundler/setup'

require 'slop'
require 'socket'
require 'open-uri'
require 'nokogiri'
require 'pop-zap'
require 'growl'
require 'opengl'

opts = Slop.parse do
  banner "ruby -Ilib bin/app.rb [options]"
  on :c, '--conf', 'Set configuration path', :argument => :optional
  on :r, '--remocon', 'Run as Key Remocon mode'
  on :h, '--help', 'Print this message'
end

if opts.help?
  puts opts.help
  exit 1
end

conf = opts.conf? ? opts[:conf] : 'conf'
mode = opts.remocon? ? 'remocon' : 'app'

if mode == 'app'
  pop_zap = PopZap::App.new(conf)
else
  pop_zap = PopZap::KeyRemocon.new(conf)
end
pop_zap.start
