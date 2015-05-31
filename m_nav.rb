require_relative 'simulation'
require_relative 'multi_simulation'

puts "母基金净值分析 - 样本数：100"
puts "-" * 80
puts "利率上浮\t母基净值\t平均PV"

["3", "4", "5"].each do |premium|
  ["0.65", "0.80", "1.00", "1.20", "1.45"].each do |m_nav|
    base = Simulation.new(m: BigDecimal.new(premium) / 100, m_nav: BigDecimal.new(m_nav))
    multi_sim = MultiSimulation.new(base: base, size: 100)
    multi_sim.perform
    puts "#{premium}%\t#{m_nav}\t#{multi_sim.mean_pv.round(2)}"
  end
end
