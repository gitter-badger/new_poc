
require 'spec_helper'

require 'cco/base'

# Cross-layer conversion objects (CCOs).
module CCO
  describe Base do
    let(:klass) { Base }

    it 'has a .from_entity class method' do
      p = klass.public_method :from_entity
      expect(p.receiver).to be klass
    end

    it 'has a .to_entity class method' do
      p = klass.public_method :to_entity
      expect(p.receiver).to be klass
    end

    describe 'has an .attr_names class method' do

      it 'that takes no parameters' do
        p = klass.public_method :attr_names
        expect(p).to have(0).parameters
      end

      it 'that raises an error unless overridden' do
        message = 'Must be overridden in subclass'
        expect { klass.attr_names }.to raise_error NoMethodError, message
      end
    end # describe 'has an .attr_names class method'

    describe 'has an .entity class method' do

      it 'that takes no parameters' do
        p = klass.public_method :entity
        expect(p).to have(0).parameters
      end

      it 'that raises an error unless overridden' do
        message = 'Must be overridden in subclass'
        expect { klass.entity }.to raise_error NoMethodError, message
      end
    end # describe 'has an .entity class method'

    describe 'has a .model class method' do

      it 'that takes no parameters' do
        p = klass.public_method :model
        expect(p).to have(0).parameters
      end

      it 'that raises an error unless overridden' do
        message = 'Must be overridden in subclass'
        expect { klass.model }.to raise_error NoMethodError, message
      end
    end # describe 'has a .model class method'

    describe 'has a .model_instance_based_on class method' do
      let(:method) { klass.public_method :model_instance_based_on }

      it 'that takes one parameter' do
        expect(method).to have(1).parameter
      end

      it 'that by default simply instantiates a new model' do
        source = method.source.lines
        source.shift    # ignore the method-definition line
        source.pop      # ignore the 'end' line
        expect(source).to have(1).line
        expect(source.each(&:strip!).join).to eq 'model.new'
      end
    end # describe 'has a .model_instance_based_on class method'

    context 'with a bare-minimum override' do
      before :each do
        # Dummy ActiveModel implementation model for CCO test
        class TestModel
          include ActiveAttr::BasicModel
          attr_accessor :foo
          validates :foo, inclusion: { in: [0, 2, 4, 6, 8] }
        end
        # Dummy entity class for CCO test
        class TestRig
          attr_reader :foo
          def initialize(params = {})
            @foo = params.fetch :foo
          end
        end

        # Base subclass to test Base functionality.
        class TestRigCCO < Base
          def self.attr_names
            [:foo]
          end
          def self.entity
            TestRig
          end
          def self.model
            TestModel
          end
        end # class TestRig
      end

      describe :to_entity do
        let(:foo) { 4 }
        let(:impl) do
          ret = TestModel.new
          ret.foo = foo
          ret
        end
        let(:entity) { TestRigCCO.to_entity impl }

        it 'produces an entity with the attributes of the input model' do
          expect(entity.foo).to eq impl.foo
        end
      end # describe :to_entity

      describe :from_entity do
        let(:foo) { 8 }
        let(:entity) { TestRig.new foo: foo }
        let(:impl) { TestRigCCO.from_entity entity }

        it 'instantiates a model with the attributes of the input entity' do
          expect(impl.foo).to eq entity.foo
        end

        it 'produces a valid model instance given valid inputs' do
          expect(impl).to be_valid
        end
      end # describe :from_entity
    end # context 'with a bare-minimum override' do
  end # describe Base
end # module CCO
