# -*- coding: utf-8 -*-
module PopZap
  class App
    LIVE_URL = 'http://tv2ch.nukos.net/tvres.html'
    IGNORE_KEYWORDS = ['BS実況', 'スカパー', '番組']

    def initialize(conf)
      @conf = conf
      @tv_conf = YAML.parse_file("#{conf}/tv.conf").transform
      @iremocon_conf = YAML.parse_file("#{conf}/i-remocon.conf").transform
    end

    def start
      prev_channel = ''
      loop do
        popular_channel = popular_channels.first
        unless prev_channel == popular_channel
          Growl.notify "#{popular_channel[:program]} - #{popular_channel[:channel]}"
          show popular_channel[:channel]
          prev_channel = popular_channel
        end

        sleep 300
      end
    end

    def popular_channels
      channels = []

      doc = Nokogiri::HTML(open(LIVE_URL))
      trs = doc.css('table.table3 tr')
      trs.each do |tr|
        tds = tr.css('td')
        next unless tds.size > 0

        channel = tds[0].inner_text.gsub("\n", '').gsub('の勢い', '')
        rate = tds[1].inner_text.gsub("\n", '').gsub('res/分', '').to_i
        program = tds[3].inner_text

        matches = channel.match(/#{IGNORE_KEYWORDS.join('|')}/)
        next unless matches.nil?

        channels << { :channel => channel, :rate => rate, :program => program }
      end

      channels.sort {|a, b| a[:rate] <=> b[:rate] }.reverse
    end

    def show(channel)
      channel_id = @tv_conf[channel]
      raise if channel_id.nil?
      sock = TCPSocket.new @iremocon_conf['ip'], @iremocon_conf['port']

      sock.write "*is;#{channel_id}\r\n"
      sock.close
    end

  end
end
