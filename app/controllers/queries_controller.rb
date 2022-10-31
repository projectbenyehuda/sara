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
