class Blog < ActiveFile::Base
  self.base_directory = File.expand_path(File.join('~', 'blogs'))
  self.location = ["**", :name, "org"]
  acts_as_org
  acts_as_git

  def self.git() Git.init(self.base_directory) end
  def title() (self.to_html(:full_html => true).match(/<title>(.*)<\/title>/) and $1) end
  def comment_section() self.body[$~.end(0)..-1] if self.body.match(/^\* COMMENT Comments$/) end
  def comments() Comment.parse(self.comment_section) end

  # ensure that the body has one and only one line that looks like
  #
  #    * COMMENT Comments
  #
  # to separate the blog from the comments
  def ensure_comments_section
    if self.comment_section
      self.body[$~.end(0)..-1] = self.body[$~.end(0)..-1].gsub(/^\* COMMENT Comments/, '')
    else
      self.body << "\n* COMMENT Comments\n"
    end
  end

end
