module Admin
  class AnnouncementsController < BaseController
    before_action :set_admin_nav

    def index
      @announcements = Announcement.ordered
      @new_announcement = Announcement.new
    end

    def create
      announcement = Announcement.new(announcement_params)

      if announcement.save
        redirect_to admin_announcements_path, notice: "Announcement created."
      else
        redirect_to admin_announcements_path, alert: announcement.errors.full_messages.to_sentence
      end
    end

    def update
      announcement = Announcement.find(params[:id])

      if announcement.update(announcement_params)
        redirect_to admin_announcements_path, notice: "Announcement updated."
      else
        redirect_to admin_announcements_path, alert: announcement.errors.full_messages.to_sentence
      end
    end

    def destroy
      Announcement.find(params[:id]).destroy
      redirect_to admin_announcements_path, notice: "Announcement deleted."
    end

    private

    def set_admin_nav
      @admin_nav_current = :announcements
    end

    def announcement_params
      params.require(:announcement).permit(:text, :active)
    end
  end
end
