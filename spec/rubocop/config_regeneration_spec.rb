# frozen_string_literal: true

RSpec.describe RuboCop::ConfigRegeneration, :isolated_environment do
  include FileHelper

  subject(:config_regeneration) { described_class.new }

  describe '#options' do
    subject { config_regeneration.options }

    context 'when no todo file exists' do
      it { is_expected.to eq(auto_gen_config: true) }
    end

    context 'when there is a blank todo file' do
      before { create_file('.rubocop_todo.yml', nil) }

      it { is_expected.to eq(auto_gen_config: true) }
    end

    context 'when the todo file is malformed' do
      before { create_file('.rubocop_todo.yml', 'todo') }

      it { is_expected.to eq(auto_gen_config: true) }
    end

    context 'it parses options from the generation comment' do
      let(:header) do
        <<~HEADER
          # This configuration was generated by
          # `rubocop --auto-gen-config --auto-gen-only-exclude --exclude-limit 100 --no-offense-counts --no-auto-gen-timestamp`
          # on 2020-06-12 17:42:47 UTC using RuboCop version 0.85.1.
        HEADER
      end

      let(:expected_options) do
        {
          auto_gen_config: true,
          auto_gen_only_exclude: true,
          exclude_limit: '100',
          offense_counts: false,
          auto_gen_timestamp: false
        }
      end

      before { create_file('.rubocop_todo.yml', header) }

      it { is_expected.to eq(expected_options) }
    end
  end
end