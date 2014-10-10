class Contentr::Admin::ApplicationController < Contentr::ApplicationController
  include ApplicationControllerExtension

  before_action :check_authorization
  before_action :set_layout

  before_filter do
    Contentr.layout_type = params[:layout_type] || 'admin'
  end

  def check_authorization
    #redirect_to main_app.root_path unless can? :manage, :cms
  end

  def default_url_options(options={})
    logger.debug "default_url_options is passed options: #{options.inspect}\n"
    { layout_type: (Contentr.layout_type || 'admin') }
  end

  protected
    def set_layout
      if params[:layout_type] == 'embedded'
        self.class.layout 'embedded'
      else
        self.class.layout 'application'
      end
    end

  private

  def current_ability
    @current_ability ||= Ability.new(current_user, params, self)
  end
end
