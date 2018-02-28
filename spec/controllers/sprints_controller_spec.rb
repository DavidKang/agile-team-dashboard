require 'rails_helper'

RSpec.describe SprintsController, type: :controller do
  let(:user) { create :user }
  let(:sprint) { create :sprint, number: 32 }

  before do
    sign_in user
  end

  describe 'POST #create' do
    subject { post :create, params: { sprint: { number: 33, start_date: '2018-02-12',
                                        end_date: '2018-02-23' } } }

    it { expect { subject }.to change(Sprint, :count).by(1) }
    it { expect(subject).to redirect_to(sprints_path) }
  end

  describe 'PATCH #update' do
    let(:update_action) { patch :update, params: { id: sprint.id, sprint: { number: 34 } } }

    it { expect { update_action }.to change { sprint.reload.number }.from(32).to(34) }
  end

  describe 'DELETE #destroy' do
    before do
      sprint
    end

    subject { delete :destroy, params: { id: sprint.id } }

    it { expect{ subject }.to change(Sprint, :count).by(-1) }
    it { expect(subject).to redirect_to(sprints_path) }
  end

  describe 'GET #start' do
    subject { get :start, params: { sprint_id: sprint.id } }

    it 'trollolo is called' do
      expect_any_instance_of(SprintsController).to receive(:system).with(/\Atrollolo burndown/)
      subject
    end
  end
end
