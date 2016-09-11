class ChartsController < ApplicationController
  def new
  end

  def create
    @random = LehmerRandom.new(*random_params)
    @rand_array = []
    find_period
    init_bar_chart
    calculate_stat_values
    check_uniformity
  end

  private

  def random_params
    params[:chart].values.map(&:to_i)
  end

  def init_bar_chart
    n = @rand_array.length
    partscount = 20
    part_length = 1.0 / partscount

    @frequency = Array.new partscount, 0.0
    @x_values = Array.new partscount, 0

    @x_values[0] = 0.0245
    (1...partscount).each { |i| @x_values[i] = @x_values[i - 1] + 1.0 / partscount }

    (0...partscount).each do |i|
      (0...n).each do |j|
        if (@rand_array[j] >= i * part_length) && (@rand_array[j] < (i + 1) * part_length)
          @frequency[i] += 1
        end
      end
      @frequency[i] /= n
    end

    @chart_values = Hash[@x_values.zip(@frequency)]
  end

  def check_uniformity
    k = 0.0
    n = @rand_array.length

    (0...n).step(2).each do |i|
      break if i + 1 >= n
      k += 1 if @rand_array[i]**2 + @rand_array[i + 1]**2 < 1
    end

    @kn2 = 2 * k / n
  end

  def calculate_stat_values
    @mx = 0
    (0...@rand_array.length).each { |i| @mx += @rand_array[i] }
    @mx /= @rand_array.length

    @dx = 0
    (0...@rand_array.length).each { |i| @dx += (@rand_array[i] - @mx)**2 }
    @dx /= @rand_array.length - 1

    @sko = Math.sqrt(@dx)
  end

  def find_period
    (0...2_000_000).each do |_|
      @rand_array.push(@random.next)
    end

    xv = @random.current

    @random.reset
    i1 = -1
    i2 = -1
    flag = false

    (0...@rand_array.length).each do |i|
      next if @rand_array[i] != xv
      if flag
        i2 = i
        break
      else
        flag = true
        i1 = i
        next
      end
    end
    period = i2 - i1

    i3 = 0
    i3 += 1 while @rand_array[i3] != @rand_array[i3 + period]
    aperiod = i3 + period

    @rand_array.slice!(aperiod, @rand_array.length - aperiod)
   
    if i2 == -1 || i1 == -1
      @period = 'No period'
    else
      @period = period
      @no_period = aperiod
    end
  end
end
