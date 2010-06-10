class Name
  attr_reader :verbatim, :scientific, :name, :start_pos, :end_pos, :score 
  
  def initialize(name, start_pos, score=100)
    @name = name
    @verbatim = @name.sub(/\[.*\]/, '.')
    @scientific = @name.gsub(/(\[|\])/, '')
    @start_pos = start_pos
    @end_pos = start_pos + @verbatim.length
    @end_pos -= 1
    @score = score
    words = @verbatim.split
    # the start position that gets passed in is actually
    # the position of the word PAST the entire string here
    # so we want to subtract each word and a space from both
    # the start and end positions.
    words.each do |word|
      @start_pos -= word.length
      @start_pos -= 1
      @end_pos -= word.length
      @end_pos -= 1
    end
  end
end