require 'rails_helper'

describe IgnoredItemsController do
  let!(:project) { create :project }

  describe '#create' do
    subject(:call) { post :create, params: { project_id: project.id, ignored_item: { external_id: 123, source: :pby } } }

    it 'creates new record and return OK status' do
      expect { call }.to change { project.ignored_items.count }.by(1)
      item = project.ignored_items.order(id: :desc).first
      expect(item).to have_attributes(external_id: '123', source: 'pby')
      expect(response).to be_successful
    end
  end

  describe '#destroy' do
    let!(:ignored_item) { create(:ignored_item, project: project) }
    subject(:call) { delete :destroy, params: { id: ignored_item.id} }

    it 'destroys ignored item record and returns OK stat' do
      expect { call }.to change { project.ignored_items.count }.by(-1)
      expect(response).to be_successful
      expect { ignored_item.reload }.to raise_error ActiveRecord::RecordNotFound
    end
  end
end
