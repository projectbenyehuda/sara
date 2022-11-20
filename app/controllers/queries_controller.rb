class QueriesController < ApplicationController
  before_action :set_models

  def create
    text = params.require(:query).permit(:text)[:text].squish
    # checking if project already has query with such title
    q = @project.queries.find_by(text: text)
    if q.nil?
      # if not we create new query in project, otherwise old query will be reused
      q = @project.queries.create!(text: text)
    end
    SearchService.call(q)

    redirect_to q
  end

  def show
    @query = Query.find(params[:id])
    @header_partial = 'queries/show_top'
    @sources = params['ckb_sources']
    @media_types = params['ckb_types']
    @items = @query.response_items.without_ignored
    @items = @items.merge(ResponseItem.where(source: @sources)) if @sources.present?
    @items = @items.merge(ResponseItem.where(media_type: @media_types)) if @media_types.present?
  end

  def set_models
    project_id = params[:project_id]
    if project_id.present?
      @project = Project.find(project_id)
    else
      id = params[:id]
      if id.present?
        @query = Query.find(id)
      end
    end
  end
end
