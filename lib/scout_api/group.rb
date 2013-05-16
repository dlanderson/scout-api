# Groups represent a collection of servers.
class Scout::Group < Hashie::Mash
  # Retrieve metric information. See {Scout::Metric.average} for a list of options for the calculation
  # methods (average, minimum, maximum).
  # 
  # GROUP QUERIES ARE NO LONGER SUPPORTED IN THE SCOUT API.
  #
  attr_reader :metrics

  # 2nd parameter is ignored/a hack because of this open Hashie issue: https://github.com/intridea/hashie/issues/14
  def initialize(hash, ignore=nil) #:nodoc:
    @metrics = Scout::MetricProxy.new(self)
    super(hash)
  end
  
  # Finds the first group that meets the given conditions. Possible parameter formats:
  # 
  #  Scout::Group.first
  #  Scout::Group.first(1)
  #  Scout::Group.first(:name => 'db slaves')
  #
  # For the <tt>:name</tt>, a {MySQL-formatted Regex}[http://dev.mysql.com/doc/refman/5.0/en/regexp.html] can be used.
  #
  # @return [Scout::Group]
  def self.first(id_or_options = nil)
    if id_or_options.nil?
      response = Scout::Account.get("/groups.xml?limit=1")
      Scout::Group.new(response['groups'].first)
    elsif id_or_options.is_a?(Hash)
      if name=id_or_options[:name]
        response = Scout::Account.get("/groups.xml?name=#{CGI.escape(name)}")
        raise Scout::Error, 'Not Found' if response['groups'].nil?
        Scout::Group.new(response['groups'].first)
      else
        raise Scout::Error, "Invalid finder condition"
      end
    elsif id_or_options.is_a?(Fixnum)
      response = Scout::Account.get("/groups/#{id_or_options}.xml")
      Scout::Group.new(response['group'])
    else
      raise Scout::Error, "Invalid finder condition"
    end
  end
  
  # Finds all groups that meets the given conditions. Possible parameter formats:
  # 
  #  Scout::Group.all
  #  Scout::Group.all(:name => 'web')
  #
  # For the <tt>:name</tt>, a {MySQL-formatted Regex}[http://dev.mysql.com/doc/refman/5.0/en/regexp.html] can be used.
  #
  # @return [Array] An array of Scout::Group objects
  def self.all(options = {})
    if name=options[:name]
      response = Scout::Account.get("/groups.xml?name=#{CGI.escape(name)}")
    elsif options.empty?
      response = Scout::Account.get("/groups.xml")
    else
      raise Scout::Error, "Invalid finder condition"
    end
    response['groups'] ? response['groups'].map { |g| Scout::Group.new(g) } : Array.new
  end
  
end