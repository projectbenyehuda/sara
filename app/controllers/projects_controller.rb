class ProjectsController < ApplicationController
  before_action :set_model, except: [:index, :create]

  def index
    @projects = Project.order(created_at: :desc)
  end

  def create
    p = Project.new(params.require(:project).permit(:title))
    if p.save
      flash.notice = t('.success')
      redirect_to p
    else
      flash.alert = t('.failed', errors: p.errors.full_messages.join(', '))
      redirect_to action: :index
    end
  end

  def edit

  end

  def update
    attrs = params.require(:project).permit(:title)
    @project.attributes = attrs
    if @project.save
      redirect_to @project, notice: t('.success')
    else
      flash.now.alert = t('.failed', errors: @project.errors.full_messages.join(', '))
      render :edit, status: :unprocessable_entity
    end
  end

  def show
    @queries = @project.queries.select(:id, :created_at, :text)
                       .select('count(*) as responses_quantity')
                       .left_joins(:response_items)
                       .group(Arel.sql('queries.id'))
                       .order(:created_at)
  end

  def destroy
    @project.destroy!
    redirect_to action: :index
  end

  private

  def set_model
    id = params[:id]
    @project = Project.find(id)
  end
end
