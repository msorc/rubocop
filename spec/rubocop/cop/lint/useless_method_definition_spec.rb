# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::UselessMethodDefinition, :config do
  subject(:cop) { described_class.new(config) }

  let(:cop_config) do
    { 'AllowComments' => true }
  end

  it 'registers an offense and corrects for empty constructor' do
    expect_offense(<<~RUBY)
      class Foo
        def initialize(arg1, arg2)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^ Useless method definition detected.
        end
      end
    RUBY

    expect_correction(<<~RUBY)
      class Foo
        
      end
    RUBY
  end

  it 'does not register an offense for constructor with only comments' do
    expect_no_offenses(<<~RUBY)
      def initialize(arg)
        # Comment.
      end
    RUBY
  end

  it 'does not register an offense for constructor containing additional code to `super`' do
    expect_no_offenses(<<~RUBY)
      def initialize(arg)
        super
        do_something
      end
    RUBY
  end

  it 'does not register an offense for empty class level `initialize` method' do
    expect_no_offenses(<<~RUBY)
      def self.initialize
      end
    RUBY
  end

  it 'registers an offense and corrects for method containing only `super` call' do
    expect_offense(<<~RUBY)
      class Foo
        def useful_instance_method
          do_something
        end

        def instance_method
        ^^^^^^^^^^^^^^^^^^^ Useless method definition detected.
          super
        end

        def instance_method_with_args(arg)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Useless method definition detected.
          super(arg)
        end

        def self.useful_class_method
          do_something
        end

        def self.class_method
        ^^^^^^^^^^^^^^^^^^^^^ Useless method definition detected.
          super
        end

        def self.class_method_with_args(arg)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Useless method definition detected.
          super(arg)
        end

        class << self
          def self.other_useful_class_method
            do_something
          end

          def other_class_method
          ^^^^^^^^^^^^^^^^^^^^^^ Useless method definition detected.
            super
          end

          def other_class_method_with_args(arg)
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Useless method definition detected.
            super(arg)
          end
        end
      end
    RUBY

    expect_correction(<<~RUBY)
      class Foo
        def useful_instance_method
          do_something
        end

        

        

        def self.useful_class_method
          do_something
        end

        

        

        class << self
          def self.other_useful_class_method
            do_something
          end

          

          
        end
      end
    RUBY
  end

  it 'does not register an offense for method containing additional code to `super`' do
    expect_no_offenses(<<~RUBY)
      def method
        super
        do_something
      end
    RUBY
  end

  it 'does not register an offense when `super` arguments differ from method arguments' do
    expect_no_offenses(<<~RUBY)
      def method1(foo)
        super(bar)
      end

      def method2(foo, bar)
        super(bar, foo)
      end
    RUBY
  end

  it 'does not register an offense when non-constructor contains only comments' do
    expect_no_offenses(<<~RUBY)
      def non_constructor
        # Comment.
      end
    RUBY
  end

  context 'when AllowComments is false' do
    let(:cop_config) do
      { 'AllowComments' => false }
    end

    it 'registers an offense when constructor contains only comments' do
      expect_offense(<<~RUBY)
        class Foo
          def initialize
          ^^^^^^^^^^^^^^ Useless method definition detected.
            # Comment.
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        class Foo
          
        end
      RUBY
    end
  end
end