require 'rails_helper'

describe QueriesController do
  describe 'Collection Actions' do
    before do
      create_list(:query, 5)
    end

    describe '#index' do
      subject! { get :index }
      it { is_expected.to be_successful }
    end

    describe '#create' do
      subject(:call) { post :create, params: { query: { text: 'New Query' } } }

      before do
        expect_any_instance_of(Search::PbySearchProvider).to receive(:call).and_return(build_list(:search_response_item, 5))
        expect_any_instance_of(Search::NliSearchProvider).to receive(:call).and_return(build_list(:search_response_item, 3))
      end

      it 'creates new Query record' do
        expect { call }.to change { Query.count }.by(1)
        q = Query.order(id: :desc).first

        expect(q).to have_attributes(text: 'New Query')
        expect(q.response_items.source_pby.count).to eq 5
        expect(q.response_items.source_nli.count).to eq 3
      end
    end
  end

  describe 'Member Actions' do
    let! (:query) { create(:query) }

    describe '#show' do
      subject { get :show, params: { id: query.id }}

      it {
        is_expected.to be_successful
      }
    end
  end

end
