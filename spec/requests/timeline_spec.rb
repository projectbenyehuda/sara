require 'rails_helper'

RSpec.describe "Timelines", type: :request do
  describe "GET /index" do
    subject! { get '/timelines' }

    it 'completes successfully' do
      expect(response).to have_http_status(:ok)
    end
  end
end
