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

  def outline
    @sara_mode = :outline
    @favorite_items = @project.favorite_items
    @wikipedia_url = ''
    @wikipedia_snippet = ''
    @outline = prep_outline
  end

  def outline_download
    @favorite_items = @project.favorite_items
    @outline = prep_outline
    send_data "<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\"><html xmlns=\"http://www.w3.org/1999/xhtml\" xml:lang=\"he\" lang=\"he\" dir=\"rtl\"><head><meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" /></head><body dir='rtl' align='right'><div dir=\"rtl\" align=\"right\">#{@outline}</div></body></html>", filename: t('.filename', title: @project.title)
  end
  private

  def set_model
    id = params[:id]
    @project = Project.find(id)
  end

  def prep_outline_item(item)
    ret = "<p class=\"headline-4\"><a href=\"#{item.url}\">#{item.title}</a> (#{textify_media_type(item.media_type)})</p>"
    ret += "<div class='subject-picture'><a href=\"#{item.media_url}\"><img src=\"#{item.thumbnail_url}\" /></a></div>" if item.thumbnail_url.present?
    ret += "<div class='outline-content-texts'>#{item.text}<p /><p><strong>#{t(:source)}</strong>:#{textify_citation(item)}</p></div>"
    return ret
  end
  def prep_outline
    ret = "<h2>#{@project.title} – #{t('.sources')}</h2>"
    # ret += "<p><img src=\"#{item.image_url}\" /></p>"
    # ret += "<p>#{item.description}</p>"
    # if item.wikipedia_url.present? && item.wikipedia_snippet.present?
      # ret += "<h3><a href=\"#{item.wikipedia_url}\">#{t(:wikipedia)}</a></h3>"
      # ret += "<p>#{item.wikipedia_snippet}</p>"
    # end
    @project.favorite_items.each do |item|
      ret += prep_outline_item(item)
    end
    ret
=begin             .outline-content-item
          .outline-content-texts
            %a{:href => ""} מתוך ויקיפדיה העברית
            %p הטקסט מוגש בכפוף לרשיון
            %p ייחוס-שיתוף זהה Creative commons 3.0
        .outline-content-item
          .outline-content-texts
            %p.headline-4 יעקב פיכמן: מבחר מאמרי ביקורת על יצירתו - מבוא וביבליוגרפיה. נורית גוברין
            %p תל אביב: עם עובד: 1971
            %p גוברין, נ׳. (1971). יעקב פיכמן: מבחר מאמרי ביקורת על יצירתו [מבוא וביבליוגרפיה]. [גרסה אלקטרונית]. https://benyehuda.org/read/19154. פרויקט בן־יהודה.
        .outline-content-item
          .outline-content-texts
            %p.headline-4 הסיפור ״מצולה״ ומקורותיו
            %p בתוך: ״מעגלים״
            %p רמת-גן: אגודת הסופרים העברים בישראל ליד הוצאת מסדה, 1975
            %p גוברין, נ׳. (1975). הסיפור ״מצולה״ ומקורותיו [גרסה אלקטרונית]. https://benyehuda.org/read/25308. פרויקט בן־יהודה. 10-01
=end
  end
end
