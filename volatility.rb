require_relative 'simulation'
require_relative 'multi_simulation'

puts "波动率分析 - 样本数：100"
puts "-" * 80
puts "利率上浮\t波动率\t平均PV"

["3", "4", "5"].each do |premium|
  ["20", "25", "30", "35"].each do |volatility|
    base = Simulation.new(m: BigDecimal.new(premium) / 100, v: BigDecimal.new(volatility) / 100)
    multi_sim = MultiSimulation.new(base: base, size: 100)
    multi_sim.perform
    puts "#{premium}%\t#{volatility}%\t#{multi_sim.mean_pv.round(2)}"
  end
end
