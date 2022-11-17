class ResponseItemsController < ApplicationController
  before_action :set_model, only: [ :toggle_favorite ]

  def toggle_favorite
    # We may have same external item returned by several queries inside same project.
    # So we need to update all of them
    # TODO: refactor system to avoid items duplication
    @response_item.project.response_items.
      where(source: @response_item.source, external_id: @response_item.external_id).
      update_all(favorite: params[:value])

    head :ok
  end

  private

  def set_model
    @response_item = ResponseItem.find(params[:id])
  end
end
