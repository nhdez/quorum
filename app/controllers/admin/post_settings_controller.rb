module Admin
  class PostSettingsController < BaseController
    before_action :set_admin_nav
    before_action :set_post_setting

    def edit
    end

    def update
      if @post_setting.update(post_setting_params)
        redirect_to edit_admin_post_settings_path, notice: "Post settings saved."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    private

    def set_admin_nav
      @admin_nav_current = :post_settings
    end

    def set_post_setting
      @post_setting = PostSetting.instance
    end

    def post_setting_params
      params.require(:post_setting).permit(:max_word_count)
    end
  end
end
