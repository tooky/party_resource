class OtherClass < OpenStruct
  def ==(other)
    self.class == other.class && super
  end
end

