require File.join(File.dirname(__FILE__), '..', 'helper')

class Quacker
  extend DecentExposure
  def self.helper_method(*args); end
  def self.hide_action(*args); end
  def self.find(*args); end
  def memoizable(*args); args; end
  def params; {'proxy_id' => 42}; end
  expose(:proxy)
  expose(:quack){ memoizable('quack!') }
end

describe DecentExposure do
  context "classes extending DecentExposure" do
    it "respond to :expose" do
      Quacker.respond_to?(:expose).should be_true
    end
  end

  context "#expose" do
    let(:instance){ Quacker.new }

    it "creates a method with the given name" do
      Quacker.new.methods.map{|m| m.to_s}.should include('quack')
    end

    it "prevents the method from being a callable action" do
      Quacker.expects(:hide_action).twice
      Quacker.class_eval do
        expose(:blerg){ 'ehm' }
      end
    end

    it "declares the method as a helper method" do
      Quacker.stubs(:hide_action)
      Quacker.expects(:helper_method).twice
      Quacker.class_eval do
        expose(:blarg){ 'uhm' }
      end
    end

    it "returns the value of the method" do
      instance.quack.should == %w(quack!)
    end

    it "memoizes the value of the created method" do
      instance.expects(:memoizable).once.returns('value')
      instance.quack
      instance.quack
    end

    context "when no block is given" do
      before do
        instance.stubs(:_class_for).returns(Quacker)
      end
      it "attempts to guess the class of the resource to expose" do
        instance.expects(:_class_for).with(:proxy).returns(Quacker)
        instance.proxy
      end
      it "calls find with {resource}_id on the resources class" do
        Quacker.expects(:find).with(42)
        instance.proxy
      end
      context "and there is no {resource}_id" do
        before do
          Quacker.class_eval do
            def params; {'id' => 24}; end
          end
        end
        it "calls find with params[:id] on the resources class" do
          Quacker.expects(:find).with(24)
          instance.proxy
        end
      end
    end
  end

  describe '#_class_for' do
    let(:name){ 'quacker' }
    let(:classified_name){ 'Quacker' }
    before do
      name.stubs(:to_s => name, :classify => classified_name)
      classified_name.stubs(:constantize => Quacker)
    end
    it 'retrieves a string representation of the class name' do
      name.expects(:classify).returns(classified_name)
      Quacker.send(:_class_for,name)
    end
    it 'returns the string representation of the name as a constant' do
      classified_name.expects(:constantize)
      Quacker.send(:_class_for,name)
    end
  end
end
