require 'rails_helper'

describe ResponseItem do
  describe 'scopes' do
    describe '.without_ignored' do
      let!(:project) { create(:project, ignored_items: []) }
      let(:query) { project.queries.first }
      let(:response_item) { query.response_items.last }

      let(:all_response_item_ids) { ResponseItem.pluck(:id).sort }
      let(:all_query_response_item_ids) { query.response_items.pluck(:id).sort }

      let(:scoped_query_response_item_ids) { query.response_items.without_ignored.pluck(:id).sort }
      let(:scoped_all_response_item_ids) { ResponseItem.without_ignored.pluck(:id).sort }

      context 'when no IgnoredItems exists' do
        it 'returns all items' do
          expect(scoped_query_response_item_ids).to eq(all_query_response_item_ids)
          expect(scoped_all_response_item_ids).to eq(all_response_item_ids)
        end
      end

      context 'when there is an IgnoredItem record' do
        let(:response_item) { query.response_items.first }

        context 'when IgnoredItem record belongs to same project as query' do
          let!(:ignored_item) do
            create(
              :ignored_item,
              project: project,
              source: response_item.source,
              external_id: response_item.external_id
            )
          end

          it 'returns all items without ignored' do
            expect(scoped_query_response_item_ids).to eq(all_query_response_item_ids - [response_item.id])
            expect(scoped_all_response_item_ids).to eq(all_response_item_ids - [response_item.id])
          end
        end

        context 'when IgnoredItem record belongs to different project than query' do
          let!(:another_project) { create(:project) }
          let!(:ignored_item) do
            create(
              :ignored_item,
              project: another_project,
              source: response_item.source,
              external_id: response_item.external_id
            )
          end

          it 'returns all items' do
            expect(scoped_query_response_item_ids).to eq(all_query_response_item_ids)
            expect(scoped_all_response_item_ids).to eq(all_response_item_ids)
          end
        end
      end
    end
  end
end
