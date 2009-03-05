class CommentNestingError < StandardError; end
class Comment
  attr_accessor :raw
  def self.build(level, title, author, body)
    raise CommentNestingError unless level > 1
    c = Comment.new(
                    <<RAW
#{'*' * level} #{title}
  :PROPERTIES:
  :author:   #{author}
  :date:     #{DateTime.now.strftime('<%Y-%m-%d %a %H:%M>')}
  :END:

#{body.gsub(/^(\*+)/,'').chomp}
RAW
                    )
    c
  end
  def initialize(raw) self.raw = raw end
  
  def level() $1.size if self.raw.match(/^(\*+)/) end
  def title() $1 if self.raw.split("\n").first.match(/^\*+ (.+)$/) end
  def properties
    props = {}
    self.raw.split("\n").
      each{ |prop_line| props[$1.intern] = $2 if prop_line.match(/^[ \t]+:(.+):[ \t]+(.*)$/) } if
      raw.match(/^[ \t]+:PROPERTIES:(.*):END:/m)
    props
  end
  def author() self.properties[:author] end
  def date() DateTime.parse(self.properties[:date]) end
  def body() self.raw[$~.end(0)..-1] if self.raw.match(/^$/) end

  # parse text returning a list of comments
  def self.parse(text)
    comments = []
    while (text and (text.match(/(^\*.*?\n)\*/m) or text.match(/(^\*.*\n)/m)))
      comments << Comment.new($1)
      text = text[$~.end(1)..-1]
    end
    comments
  end
  
end
