# -*- coding: utf-8 -*-
module PopZap
  class App
    LIVE_URL = 'http://tv2ch.nukos.net/tvres.html'
    IGNORE_KEYWORDS = ['BS実況', 'スカパー', '番組']
    POPULAR_RATE = 1.05
    MESSAGE_DIR = File.join(Dir.home, '.pop-zap')

    def initialize(conf, options = {})
      @channel_conf = { }
      tv_conf = YAML.parse_file("#{conf}/tv.conf").transform
      tv_conf[:channels].each do |name, setting|
        @channel_conf[name] = setting[:remocon]
      end
      @iremocon_conf = YAML.parse_file("#{conf}/i-remocon.conf").transform

      @voice = options.has_key?(:voice) ? options[:voice] : false
      generate_voice_file(conf)
    end

    def generate_voice_file(conf)

      return if File.exist?(MESSAGE_DIR) && File.exist?(File.join(MESSAGE_DIR, 'voice.scpt'))

      scpts = []
      open("#{conf}/voice.scpt", 'r') do |scpt|
        scpt.each do |line|
          line = line.gsub('$voice_file_path', MacTypes::FileURL.path(File.expand_path("#{MESSAGE_DIR}/channel.aiff")).hfs_path)
          scpts << line
        end
      end

      FileUtils.mkdir(MESSAGE_DIR) unless File.exist? MESSAGE_DIR

      open(File.join(MESSAGE_DIR, 'voice.scpt'), 'w') do |scpt|
        scpt.write scpts.join
      end
    end

    def start
      prev_channel = ''
      loop do
        popular_channel = popular_channels.first
        candidate_channel = popular_channels.size > 1 ? popular_channels[1] : nil

        if more_popular?(popular_channel, candidate_channel) && prev_channel != popular_channel[:channel]
          info "#{popular_channel[:program]} - #{popular_channel[:channel]}"
          show popular_channel[:channel]
          prev_channel = popular_channel[:channel]
        end

        sleep 300
      end
    end

    def more_popular?(channel_a, channel_b)
      raise if channel_a.nil? || channel_b.nil?
      (channel_a[:rate].to_f / channel_b[:rate].to_f) > POPULAR_RATE
    end

    def info(message)
      if @voice
        say message
      end
      Growl.notify message
      puts message
    end

    def say(message)
      `say -v Kyoko #{message}を映します -o #{MESSAGE_DIR}/channel.aiff`
      `osascript #{MESSAGE_DIR}/voice.scpt`
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
      channel_id = @channel_conf[channel]
      raise if channel_id.nil?
      sock = TCPSocket.new @iremocon_conf['ip'], @iremocon_conf['port']

      sock.write "*is;#{channel_id}\r\n"
      sock.close
    end

  end
end
