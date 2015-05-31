require 'active_support'
require 'active_support/core_ext'
require_relative 'simulation'

class MultiSimulation
  attr :a_pvs
  def initialize(base:, size: 100)
    @base = base
    @size = size
    @a_pvs = []
  end

  def perform
    @size.times do
      simulation = Marshal.load(Marshal.dump(@base))  # Deep copy base simulation
      simulation.perform
      @a_pvs << simulation.a_pv
    end
  end

  def mean_pv
    a_pvs.sum / a_pvs.size
  end
end
