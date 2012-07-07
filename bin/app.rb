require 'bundler/setup'

require 'slop'
require 'socket'
require 'open-uri'
require 'nokogiri'
require 'pop-zap'
require 'growl'
require 'opengl'
require 'appscript'

opts = Slop.parse do
  banner_text = []
  banner_text << "pop-zap (ver #{PopZap::VERSION})"
  banner_text << "bin/pop-zap [options]"

  banner banner_text.join("\n\n")

  on :c, '--conf', 'Set configuration path', :argument => :optional
  on :r, '--remocon', 'Run as Key Remocon mode'
  on :v, '--voice', 'Speak program information'
  on :h, '--help', 'Print this message'
end

if opts.help?
  puts opts.help
  exit 1
end

conf = opts.conf? ? opts[:conf] : 'conf'
mode = opts.remocon? ? 'remocon' : 'app'
voice = opts.voice?

if mode == 'app'
  pop_zap = PopZap::App.new(conf, :voice => voice)
else
  pop_zap = PopZap::KeyRemocon.new(conf)
end
pop_zap.start
