require 'rails_helper'

describe QueriesController do
  describe 'Collection Actions' do
    let!(:project) { create(:project) }

    describe '#create' do
      subject(:call) { post :create, params: { project_id: project.id, query: { text: 'New Query' } } }

      before do
        expect_any_instance_of(Search::PbySearchProvider).to receive(:call).and_return(build_list(:search_response_item, 6))
        expect_any_instance_of(Search::NliSearchProvider).to receive(:call).and_return(build_list(:search_response_item, 3))
      end

      it 'creates new Query record' do
        expect { call }.to change { Query.count }.by(1)
        q = Query.order(id: :desc).first

        expect(q).to have_attributes(text: 'New Query')
        expect(q.response_items.source_pby.count).to eq 6
        expect(q.response_items.source_nli.count).to eq 3
      end
    end
  end

  describe 'Member Actions' do
    let! (:query) { create(:query, response_items_count: 5) }
    let!(:project) { query.project }

    describe '#show' do
      subject { get :show, params: { id: query.id } }

      it {
        is_expected.to be_successful
      }
    end

    describe '#destroy' do
      let!(:favorite_item) do
        create(
          :response_item,
          project: project,
          query: query,
          favorite: true
        )
      end

      subject(:call) { delete :destroy, params: { id: query.id } }

      it 'destroys query, all its items except favorite and redirects to project page' do
        expect { call }.to change { Query.count }.by(-1).and change { ResponseItem.count }.by(-5)
        expect(response).to redirect_to project
        expect(flash.alert).to eq I18n.t('queries.destroy.success')
        favorite_item.reload
        expect(favorite_item.query_id).to be_nil
      end
    end
  end

end
