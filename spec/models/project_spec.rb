require 'rails_helper'

describe Project do
  describe '.favorite_items' do
    let!(:project) { create(:project) }

    # this one should be ignored, because second item has same external_id and created later
    let!(:first_item) do
      create(
        :response_item,
        project: project,
        query: project.queries[0],
        source: :pby,
        external_id: '12345',
        favorite: true
      )
    end

    let!(:second_item) do
      create(
        :response_item,
        project: project,
        query: project.queries[1],
        source: :pby,
        external_id: '12345',
        favorite: true
      )
    end

    let!(:third_item) do
      create(
        :response_item,
        project: project,
        query: project.queries[0],
        source: :nli,
        external_id: 'ABC',
        favorite: true
      )
    end

    # adding second project with favorite item to ensure it will not be returned
    let!(:other_project) { create :project }
    let!(:other_item) do
      create(
        :response_item,
        project: other_project,
        query: other_project.queries[0],
        source: :nli,
        external_id: 'OTHER',
        favorite: true
      )
    end

    it 'returns all favorite items from project, but excludes duplicating items' do
      expect(project.favorite_items.pluck(:id)).to match_array [second_item.id, third_item.id]
    end
  end
end
