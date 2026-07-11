class ApplicationController < ActionController::Base
  include Pundit::Authorization

  layout "forum"

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  Page = Struct.new(:records, :number, :total_pages)

  protected

  def user_not_authorized
    redirect_to root_path, alert: "You are not authorized to do that."
  end

  # Simple LIMIT/OFFSET pagination. Returns a Page with the sliced records
  # plus the resolved page number and total page count.
  def paginate(scope, page: params[:page], per_page: 20)
    number = page.to_i
    number = 1 if number < 1
    total_count = scope.count
    total_pages = [ (total_count.to_f / per_page).ceil, 1 ].max
    number = total_pages if number > total_pages
    records = scope.offset((number - 1) * per_page).limit(per_page)
    Page.new(records, number, total_pages)
  end

  # Builds a « 1 2 3 N » page list for Ui::PaginationComponent from a Page.
  def page_links(page, path:)
    return [] if page.total_pages <= 1

    links = []
    links << { label: "«", href: path.call(page.number - 1) } if page.number > 1
    (1..page.total_pages).each do |number|
      links << { label: number.to_s, href: path.call(number), current: number == page.number }
    end
    links << { label: "»", href: path.call(page.number + 1) } if page.number < page.total_pages
    links
  end
end
