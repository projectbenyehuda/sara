class QueriesController < ApplicationController
  def create
    text = params.require(:query).permit(:text)[:text].squish
    q = Query.find_by(text: text)
    if q.nil?
      q = Query.create!(text: text)
    end
    SearchService.call(q)

    redirect_to q
  end

  def show
    @query = Query.find(params[:id])
  end

  def index
    @records = Query.select(:id, :created_at, :text)
                    .select('count(*) as responses_quantity')
                    .left_joins(:response_items)
                    .group(Arel.sql('queries.id'))
                    .order(:created_at)
  end
end
