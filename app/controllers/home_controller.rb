class HomeController < ApplicationController
  def index
    @articles = Rails.cache.fetch 'articles' do
      Article.except_body_with_default.order('id DESC').limit(10).to_a
    end

    @hot_articles = Rails.cache.fetch 'hot_articles' do
      Article.except_body_with_default.limit(10).to_a
    end

    @groups = Rails.cache.fetch('groups', expires_in: 2.hours) do
      Group.limit(6)
    end

    @apps = Rails.cache.fetch('apps', expires_in: 2.hours) do
      App.limit(6)
    end

    @site_info_home_desc = Admin::SiteInfo.fetch_by_key('home_desc').try(:value)

    respond_to do |format|
      format.all { render :index, formats: [:html] }
    end
  end
end
