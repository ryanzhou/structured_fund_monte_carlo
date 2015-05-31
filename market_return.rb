require_relative 'simulation'
require_relative 'multi_simulation'

puts "市场回报分析 - 样本数：100"
puts "-" * 80
puts "利率上浮\t市场回报率\t平均PV"

["3", "4", "5"].each do |premium|
  ["0", "5", "10", "15"].each do |rm|
    base = Simulation.new(m: BigDecimal.new(premium) / 100, rm: BigDecimal.new(rm) / 100)
    multi_sim = MultiSimulation.new(base: base, size: 100)
    multi_sim.perform
    puts "#{premium}%\t#{rm}%\t#{multi_sim.mean_pv.round(2)}"
  end
end
