require 'rails_helper'

RSpec.describe ChartUpdater, type: :service do
  let!(:sprint) { create(:sprint, start_date: '2018-03-05', end_date: '2018-03-16') }
  let(:standup_time) { Time.zone.local(2018, 3, 6, 10, 45, 0) }
  let(:review_time) { Time.zone.local(2018, 3, 16, 12, 35, 0) }
  let(:no_update) { Time.zone.local(2018, 3, 6, 10, 0, 0) }
  let(:times) { { before_standup: 20.minutes, after_review: 30.minutes, interval: 15.minutes } }

  context '#self.update_burndown_chart' do
    subject { ChartUpdater.update_burndown_chart(sprint, times) }

    context "doesn't need to be updated" do
      before do
        Timecop.freeze(no_update)
      end

      it { expect(subject).to be_falsey }
      it 'should log error' do
        expect(Rails.logger).to receive(:error).with("The burndown chart doesn't need to be updated.")
        subject
      end
    end

    context 'needs to be updated' do
      context 'and generating the burndown chart fails' do
        before do
          Timecop.freeze(standup_time)
          allow(ChartUpdater).to receive(:generate_image_and_upload_to_trello).with(sprint.number).and_return(nil)
        end

        it { expect(subject).to be_falsey }
        it 'should log error' do
          expect(Rails.logger).to receive(:error).with('There was an error and the burndown chart was NOT updated.')
          subject
        end
      end

      context 'with a successfully burndown chart update' do
        context 'when is not the last day of the sprint' do
          before do
            Timecop.freeze(standup_time)
            allow(ChartUpdater).to receive(:generate_image_and_upload_to_trello)
              .with(sprint.number).and_return('fake.png')
          end

          it 'should move the burndon chart image to public' do
            expect(ChartUpdater).to receive(:system).with(/\Amv fake/)
            subject
          end
        end

        context 'when is the last day of the sprint' do
          context 'and the push to github repository was successfully' do
            before do
              Timecop.freeze(review_time)
              allow(ChartUpdater).to receive(:generate_image_and_upload_to_trello)
                .with(sprint.number).and_return('fake.png')
              allow(ChartUpdater).to receive(:commit_and_push).and_return(true)
              allow(ChartUpdater).to receive(:system).with(/\Amv fake/)
            end

            it 'shoud delete burndown-data file' do
              expect(File).to receive(:delete).with(%r{\Atrollolo/burndown-data}, 'rb')
              expect(Rails.logger).to receive(:info).with('Burndown chart updated!')
              expect(Rails.logger).to receive(:info).with('The burndown chart was uploaded to Github 😸')
              expect(Rails.logger).to receive(:info).with('The local burndown chart data copy was removed.')
              subject
            end
          end

          context 'and the push to github repository fails' do
            before do
              Timecop.freeze(review_time)
              allow(ChartUpdater).to receive(:generate_image_and_upload_to_trello)
                .with(sprint.number).and_return('fake.png')
              allow(ChartUpdater).to receive(:commit_and_push).and_return(false)
              allow(ChartUpdater).to receive(:system).with(/\Amv fake/)
            end

            it { expect(subject).to be_falsey }
            it 'should log the error' do
              expect(Rails.logger).to receive(:error)
                .with('There was an error and the burndown chart was NOT uploaded to Github.')
              subject
            end
          end
        end
      end
    end
  end

  context '#self.need_to_update_burndown_chart?' do
    context 'have to update the burndown chart' do
      context 'when a standup will start in 20 - 5 minutes ' do
        before do
          Timecop.freeze(standup_time)
        end

        it { expect(ChartUpdater.need_to_update_burndown_chart?(sprint, times)).to be_truthy }
      end

      context 'when a review has finished 30 - 45 minutes ago' do
        before do
          Timecop.freeze(review_time)
        end

        it { expect(ChartUpdater.need_to_upload_to_github?(sprint, times)).to be_truthy }
      end
    end

    context 'when is too soon to update the burndown chart' do
      before do
        Timecop.freeze(no_update)
      end

      it { expect(ChartUpdater.need_to_update_burndown_chart?(sprint, times)).to be_falsey }
    end
  end

  context '#self.need_to_upload_to_github?' do
    context 'when a review has finished 30 - 45 minutes ago' do
      before do
        Timecop.freeze(review_time)
      end

      it { expect(ChartUpdater.need_to_upload_to_github?(sprint, times)).to be_truthy }
    end

    context 'when is not a review and has not finished' do
      before do
        Timecop.freeze(no_update)
      end

      it { expect(ChartUpdater.need_to_upload_to_github?(sprint, times)).to be_falsey }
    end
  end
end
