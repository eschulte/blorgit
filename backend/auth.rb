require 'digest/md5'

class SimpleAuth < ActiveFile::Base
  def initialize(username, password)
    @username = username
    @password = password
  end

  def authorized?(user, password)
    @username == user and @password == password
  end

  def allowed?(user, path, perm)
    puts "AA: #{user} #{path} #{perm}"
    return true unless user == 'anonymous'
  end

end

class HintFileAuth < ActiveFile::Base

  def initialize(hints)
    @users, @groups, @rules = {}, {}, []
    puts hints
    File.readlines(hints).each do |rule|
      rule.strip!
      next if rule.start_with?('#') or rule.empty?
      case rule

        when /^adduser\s+(\S+)/
        @users[$1] = {:encrypted_password => rule[/with\s+encrypted_password\s+(\S+)/, 1]}

        when /^addgroup\s+(@\S+)/
        group = @groups[$1] = {}
        rule[/with user\s+(\S+)/, 1].split(',').each do |user|
          (group[:users] ||= []) << user
        end

        when /^path\s+(\S+)\s+(allow|deny)\s+(\S+)\s+to\s+(read|write)/
        @rules << {:rule => $1,
          :verb => $2,
          :group => $3,
          :perm => ($4 == 'read'?['read']:['read', 'write'])}

        else
        puts "warn: syntax error at line `#{rule}'"
      end
    end

    # build group 'all'
    @groups['@all'] = {}
    @users.keys.each do |user|
      (@groups['@all'][:users] ||= []) << user
    end
  end

  def allowed?(user, path, perm)
    #puts "allowed?: user=#{user}, path=#{path}, perm=#{perm}"
    @rules.each do |rule|
      next unless @groups.include? rule[:group]
      return rule[:verb] == 'allow' if path.match rule[:rule] \
      and @groups[rule[:group]][:users].include? user and rule[:perm].include? perm
    end
    false
  end

  def authorized?(user, password)
    return false unless @users.include? user
    return false unless
      @users[user][:encrypted_password] == Digest::MD5.hexdigest(password)
    return true
  end
end

if __FILE__ == $0
  auth = HintFileAuth.new "~/blogs"
  #puts auth.auth('yuting', '/', 'read')
  puts auth.login('jianingy', '12345')
end
