require 'bundler/setup'

require 'slop'
require 'socket'
require 'open-uri'
require 'nokogiri'
require 'pop-zap'
require 'growl'

opts = Slop.parse do
  banner "ruby -Ilib bin/app.rb [options]"
  on :c, '--conf', 'Set configuration path', :as => :string
  on :h, '--help', 'Print this message'
end

if opts.help?
  puts opts.help
  exit 1
end

conf = opts[:conf] || 'conf'

pop_zap = PopZap::App.new(conf)
pop_zap.start
