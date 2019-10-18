require 'yaml'
require 'erb'

class ConfigParser
  def self.parse(file, environment)
    YAML.load(ERB.new(IO.read(file)).result)[environment]
  end
end

