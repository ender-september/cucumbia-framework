# Logger class
class LoggerBuilder
  def initialize(log_file)
    @file_logger = Logger.new(log_file, 2, 1_024_000)
    @stdout_logger = Logger.new(STDOUT)
  end

  def info(msg)
    msg = "#{msg} \n"
    @file_logger.info(msg)
    @stdout_logger.info(msg)
  end

  def warn(msg)
    msg = "#{msg} \n"
    @file_logger.warn(msg)
    @stdout_logger.warn(msg)
  end

  def error(msg)
    msg = "#{msg} \n"
    puts msg
    @file_logger.error(msg)
    @stdout_logger.error(msg)
  end

  private

  attr_accessor :file_logger
  attr_accessor :stdout_logger
end
