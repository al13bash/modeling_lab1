class LehmerRandom
  attr_reader :m

  def initialize(a, m, r0)
    @a = a.to_f
    @m = m.to_f
    @r_prev = r0.to_f
    @r0 = r0.to_f
  end

  def next
    @r_prev = (@a * @r_prev) % @m
    @r_prev / @m
  end

  def reset
    @r_prev = @r0
  end

  def current
    @r_prev / @m
  end

  def current_r
    @r_prev
  end
end
