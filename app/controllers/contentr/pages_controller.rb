class Contentr::PagesController < Contentr::ApplicationController
  include Contentr::PagesControllerExtension

  def index
    possible_pages = Contentr::ContentPage.where(slug: params[:slug].split('_').last, language: I18n.locale.to_s).to_a
    if possible_pages.empty? && I18n.locale != I18n.default_locale
      possible_pages = Contentr::ContentPage.where(slug: params[:slug].split('_').last, language: I18n.default_locale.to_s).to_a
    end
    @area_containing_element = possible_pages.count == 1 ? possible_pages.first : possible_pages.find{|pp| pp.url_slug == params[:slug]}
    if @area_containing_element.present? && (@area_containing_element.viewable?(preview_mode: in_preview_mode?) || contentr_authorized?(type: :manage, object: @area_containing_element))
      @area_containing_element.preview! if in_preview_mode?
      flash.now[:notice] = t('contentr.content_not_available_in_language') if @area_containing_element.language != I18n.locale.to_s
      self.class.layout("layouts/#{Contentr.frontend_layout}")
    else
      raise ActionController::RoutingError.new('Not Found')
    end
  end

  def show
    find_page_for params
  end
end
