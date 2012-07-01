# -*- coding: utf-8 -*-
module PopZap
  class KeyRemocon
    def initialize(conf)
      load_conf(conf)
      init_socket
      init_window
    end

    def banner
      puts '[Pop-zap] Remocon mode:'
      puts ''
      puts '     Number            Change your channel'
      puts '     KeyUp/KeyDown     Change your volume'
      puts '     Enter             Exit'
    end

    def load_conf(conf)
      tv_conf = YAML.parse_file("#{conf}/tv.conf").transform

      @channel_conf, @volume_conf = { }, { }

      tv_conf[:channels].each do |name, setting|
        @channel_conf[setting[:channel]] = setting[:remocon]
      end

      tv_conf[:volumes].each do |name, setting|
        @volume_conf[name] = setting[:remocon]
      end

      @iremocon_conf = YAML.parse_file("#{conf}/i-remocon.conf").transform
    end

    def init_socket
      @sock = TCPSocket.new @iremocon_conf['ip'], @iremocon_conf['port']
    end

    def init_window
      GLUT.Init
      GLUT.InitWindowSize(1, 1)
      GLUT.InitWindowPosition(1,1)
      GLUT.CreateWindow('')
      GLUT.DisplayFunc(display)
      GLUT.KeyboardFunc(keyboard)
      GLUT.SpecialFunc(keyboard)
    end

    def start
      banner
      GLUT.MainLoop
    end

    def bye
      @sock.close
      exit 0
    end

    def keyboard
      Proc.new do |key, x, y|
        if key.is_a?(String) && ('1'..'8').include?(key)
          remocon_id = @channel_conf[key.to_i]
        elsif key == GLUT::KEY_UP
          remocon_id = @volume_conf[:up]
        elsif key == GLUT::KEY_DOWN
          remocon_id = @volume_conf[:down]
        else
          next bye
        end
        send_command remocon_id.to_s
      end
    end

    def display
      Proc.new { }
    end

    def send_command(remocon_id)
      @sock.write "*is;#{remocon_id}\r\n"
    end
  end
end
