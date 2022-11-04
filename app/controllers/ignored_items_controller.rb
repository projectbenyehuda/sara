class IgnoredItemsController < ApplicationController
  def create
    project_id = params[:project_id]
    @project = Project.find(project_id)

    attrs = params.require(:ignored_item).permit(:external_id, :source)
    rec = @project.ignored_items.build(attrs)
    if rec.save
      head :ok
    else
      render json: { errors: rec.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    id = params[:id]
    rec = IgnoredItem.find(id)
    rec.destroy
    head :ok
  end
end
