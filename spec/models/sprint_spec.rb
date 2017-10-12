require 'rails_helper'

RSpec.describe Sprint, type: :model do
  %i(number start_date end_date).each do |attr|
    it { should validate_presence_of(attr) }
  end

  context 'validate' do
    context 'start_on_weekend' do
      let(:sprint) { build(:sprint, start_date: '2017-10-07', end_date: '2017-10-12') }

      before do
        sprint.valid?
      end

      it { expect(sprint.errors.full_messages).to eq(['Start date can not be on weekend']) }
    end

    context 'end_on_weekend' do
      let(:sprint) { build(:sprint, start_date: '2017-10-06', end_date: '2017-10-08') }

      before do
        sprint.valid?
      end

      it { expect(sprint.errors.full_messages).to eq(['End date can not be on weekend']) }
    end

    context 'ends_before_start' do
      let(:sprint) { build(:sprint, start_date: '2017-10-06', end_date: '2017-10-02') }

      before do
        sprint.valid?
      end

      it { expect(sprint.errors.full_messages).to eq(['End date can not end before start']) }
    end

    context 'ends_before_start' do
      let!(:sprint) { create(:sprint, start_date: '2017-10-02', end_date: '2017-10-13') }
      let(:invalid_sprint) { build(:sprint, start_date: '2017-10-06', end_date: '2017-10-12') }

      before do
        invalid_sprint.valid?
      end

      it { expect(invalid_sprint.errors.full_messages.first).to eq('Start date cannot start in current sprint days') }
      it { expect(invalid_sprint.errors.full_messages.last).to eq('End date cannot end in current sprint days') }
    end
  end
end
