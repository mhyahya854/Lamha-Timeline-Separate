# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Map v1 sunset banners', type: :request do
  let(:user) { create(:user) }

  before { sign_in user }

  it 'always shows the general v1 sunset banner on the classic map' do
    get map_v1_path

    expect(response.body).to include('map_v1_sunset_aug_2026')
    expect(response.body).to include('August 2026')
  end

end
