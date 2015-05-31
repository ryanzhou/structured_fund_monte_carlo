require_relative 'simulation'
require_relative 'multi_simulation'

puts "折现率分析 - 样本数：100"
puts "-" * 80
puts "利率上浮\t折现率\t平均PV"

["3", "4", "5"].each do |premium|
  ["5", "8", "10"].each do |r|
    base = Simulation.new(m: BigDecimal.new(premium) / 100, r: BigDecimal.new(r) / 100)
    multi_sim = MultiSimulation.new(base: base, size: 100)
    multi_sim.perform
    puts "#{premium}%\t#{r}%\t#{multi_sim.mean_pv.round(2)}"
  end
end
