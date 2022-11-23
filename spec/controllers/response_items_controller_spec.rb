require 'rails_helper'

describe ResponseItemsController do
  describe '#toggle_favorite' do
    let(:source) { :pby }
    let(:external_id) { '12345' }

    let!(:project) { create(:project) }
    let!(:first_item) do
      create(
        :response_item,
        project: project,
        query: project.queries[0],
        source: source,
        external_id: external_id,
        favorite: favorite
      )
    end

    let!(:second_item) do
      create(
        :response_item,
        project: project,
        query: project.queries[1],
        source: source,
        external_id: external_id,
        favorite: favorite
      )
    end

    let!(:other_project) { create(:project) }

    let!(:other_item) do
      create(
        :response_item,
        project: other_project,
        query: project.queries[0],
        source: source,
        external_id: external_id,
        favorite: favorite
      )
    end

    subject (:call) { post :toggle_favorite, params: { id: first_item.id, value: !favorite } }

    context 'when we mark item as favorite' do
      let(:favorite) { false }

      it 'updates all items with given source/external_id withing single project' do
        expect { call }.to change { ResponseItem.where(favorite: true).count }.by(2)
        expect(first_item.reload.favorite).to be true
        expect(second_item.reload.favorite).to be true
        expect(other_item.reload.favorite).to be false
      end
    end

    context 'when we unmark item as favorite' do
      let(:favorite) { true }

      it 'updates all items with given source/external_id withing single project' do
        expect { call }.to change { ResponseItem.where(favorite: true).count }.by(-2)
        expect(first_item.reload.favorite).to be false
        expect(second_item.reload.favorite).to be false
        expect(other_item.reload.favorite).to be true
      end
    end
  end
end
