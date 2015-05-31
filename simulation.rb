require 'active_support'
require 'active_support/core_ext'
require 'rubystats'

class Simulation
  attr_accessor :a_nav, :b_nav, :m_nav, :a_quantity, :b_quantity, :index_val, :a_cashflows, :b_cashflows, :a_pv, :b_pv

  TRADING_DAYS = 250

  def initialize(
    a_nav: BigDecimal.new("1.0"),
    m_nav: BigDecimal.new("1.0"),
    i: BigDecimal.new("0.025"),
    m: BigDecimal.new("0.03"),
    uat: BigDecimal.new("1.5"),
    dat: BigDecimal.new("0.25"),
    r: BigDecimal.new("0.08"),
    rm: BigDecimal.new("0.10"),
    v: BigDecimal.new("0.35"),
    d: 1,
    years: 50,
    debug: false,
    show_price: false
  )
    @a_nav = a_nav
    @m_nav = m_nav
    @b_nav = 2 * m_nav - a_nav
    @index_val = BigDecimal.new("100.0")
    @uat = uat
    @dat = dat
    @a_cashflows = []
    @b_cashflows = []
    @a_pv = BigDecimal.new("0.0")
    @b_pv = BigDecimal.new("0.0")
    @r = r
    @rm = rm
    @coupon = i + m
    @v = v
    @initial_date = d
    @current_date = @initial_date
    @years = years
    @a_quantity = BigDecimal.new("10000.0")
    @b_quantity = BigDecimal.new("10000.0")
    @debug = debug
    @show_price = show_price
  end

  def perform
    while @current_date <= @initial_date + @years * TRADING_DAYS
      stock_index_movement
      coupon_settlement
      scheduled_adjustment
      upward_adjustment
      downward_adjustment
      if @show_price && @current_date % 20 == 0
        puts "#{@current_date}\t#{a_quantity.round(2)}\t#{a_nav.round(2)}\t#{b_nav.round(2)}\t#{m_nav.round(2)}\t#{index_val.round(2)}"
      end
      @current_date += 1
    end
  end

  private
  def stock_index_movement
    dist = Rubystats::NormalDistribution.new(daily_rm, daily_v)
    delta = dist.rng.round(4)
    @index_val = (@index_val * (1 + delta)).round(2)
    old_m_nav = @m_nav
    @m_nav = (@m_nav * (1 + delta)).round(4)
    @b_nav = @m_nav * 2 - @a_nav
  end

  def coupon_settlement
    interest = @a_nav * daily_coupon
    @b_nav -= interest
    @a_nav += interest
  end

  def scheduled_adjustment
    if @current_date % TRADING_DAYS == 0
      settlement = @a_nav - BigDecimal.new("1.0")
      a_income = settlement * @a_quantity
      @a_nav -= settlement
      @a_cashflows <<= [a_income, @current_date]
      @a_pv += discount(a_income).round(4)
      if @debug
        puts "#{@current_date}\t定折\t#{a_income.round(2)}\t#{discount(a_income).round(2)}\t#{@a_pv.round(2)}"
      end
    end
  end

  def upward_adjustment
    if @m_nav >= @uat
      a_settlement = @a_nav - BigDecimal.new("1.0")
      b_settlement = @b_nav - BigDecimal.new("1.0")
      a_income = a_settlement * @a_quantity
      b_income = b_settlement * @b_quantity
      @m_nav = BigDecimal.new("1.0")
      @a_nav -= a_settlement
      @a_cashflows << [a_income, @current_date]
      @a_pv += discount(a_income).round(4)
      @b_nav -= b_settlement
      @b_cashflows << [b_income, @current_date]
      @b_pv += discount(b_income).round(4)
      if @debug
        puts "#{@current_date}\t上折\t#{a_income.round(2)}\t#{discount(a_income).round(2)}\t#{@a_pv.round(2)}"
      end
    end
  end

  def downward_adjustment
    if @b_nav <= @dat
      a_settlement = @a_nav - @b_nav
      a_income = a_settlement * @a_quantity
      @a_cashflows << [a_income, @current_date]
      @a_pv += discount(a_income)
      @a_quantity *= @b_nav / BigDecimal.new("1.0")
      @b_quantity *= @b_nav / BigDecimal.new("1.0")
      @a_nav = BigDecimal.new("1.0")
      @b_nav = BigDecimal.new("1.0")
      @m_nav = BigDecimal.new("1.0")
      if @debug
        puts "#{@current_date}\t下折\t#{a_income.round(2)}\t#{discount(a_income).round(2)}\t#{@a_pv.round(2)}"
      end
    end
  end

  def daily_v
    @daily_v ||= @v * ((1.0/TRADING_DAYS) ** 0.5)
  end

  def daily_rm
    @daily_rm ||= @rm * (1.0/TRADING_DAYS)
  end

  def daily_coupon
    @daily_coupon ||= @coupon * (1.0/TRADING_DAYS)
  end

  def discount(value)
    days = @current_date - @initial_date
    value * ((1 + @r) ** -(days.to_f / TRADING_DAYS))
  end
end
