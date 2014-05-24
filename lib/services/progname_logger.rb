class PrognameLogger
  def initialize( progname )
    @progname = progname
    @logger = Logger.new( File.join( ENV['COINGATE_ROOT_PATH'], 'log', 'coingate.log' ), 'daily' )
    # @logger.datetime_format = '%Y-%m-%d %H:%M:%S '
    # @logger.formatter = proc do |severity, datetime, progname, msg|
    #   "[#{datetime} #{progname}] #{severity} : #{msg}\n"
    # end
  end

  def debug( msg )
    @logger.debug(@progname) { msg }
  end

  def info( msg )
    @logger.info(@progname) { msg }
  end

  def warn( msg )
    @logger.warn(@progname) { msg }
  end

  def error( msg )
    @logger.error(@progname) { msg }
  end

  def fatal( msg )
    @logger.fatal(@progname) { msg }
  end

  def unknown( msg )
    @logger.unknown(@progname) { msg }
  end
end
