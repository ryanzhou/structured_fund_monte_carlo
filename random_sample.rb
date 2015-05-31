require_relative 'simulation'
require_relative 'multi_simulation'

puts "随机3个样本 - 全部默认参数"
puts "天数\t操作\t收入\t折现\t累计"
base = Simulation.new(debug: true)
multi_sim = MultiSimulation.new(base: base, size: 3)
multi_sim.perform
puts "-" * 80
puts "PV算术平均值：#{multi_sim.mean_pv.round(2)}"
