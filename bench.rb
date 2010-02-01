$: << 'lib'
require 'decent_exposure'
require 'dec_exp' # I had the original decent_exposure.rb here
require 'benchmark'

# yes, the performance increase is only really obvious
# across one million iterations
n = 1_000_000

class QuackerOriginal
  extend DecExp # I renamed the original module to DecExp
  def self.helper_method(*args); end
  def self.hide_action(*args); end
  def self.find(*args); end
  def memoizable(*args); args; end
  def params; {'proxy_id' => 42}; end
  expose(:proxy)
  expose(:quack){ 'quack!' }
end

class QuackerModified
  extend DecentExposure
  def self.helper_method(*args); end
  def self.hide_action(*args); end
  def self.find(*args); end
  def memoizable(*args); args; end
  def params; {'proxy_id' => 42}; end
  expose(:proxy)
  expose(:quack){ 'quack!' }
end

Benchmark.bm do |x|
  x.report('original') do
    obj = QuackerOriginal.new
    n.times {raise "FAIL" unless obj.quack == 'quack!'}
  end
  x.report('modified') do
    obj = QuackerModified.new
    n.times {raise "FAIL" unless obj.quack == 'quack!'}    
  end
end
