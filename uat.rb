require_relative 'simulation'
require_relative 'multi_simulation'

puts "上折阈值分析 - 样本数：100"
puts "-" * 80
puts "利率上浮\t上折阈值\t平均PV"

["3", "4", "5"].each do |premium|
  ["1.50", "2.00"].each do |uat|
    base = Simulation.new(m: BigDecimal.new(premium) / 100, uat: BigDecimal.new(uat))
    multi_sim = MultiSimulation.new(base: base, size: 100)
    multi_sim.perform
    puts "#{premium}%\t#{uat}\t#{multi_sim.mean_pv.round(2)}"
  end
end
