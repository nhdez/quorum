module Admin
  class FallacyDefinitionsController < BaseController
    def index
      @admin_nav_current = :fallacy_detection
      @fallacy_definitions = FallacyDefinition.order(:display_name)
    end

    def update
      definition = FallacyDefinition.find(params[:id])
      definition.update!(fallacy_definition_params)
      redirect_to admin_fallacy_definitions_path, notice: "#{definition.display_name} updated."
    end

    private

    def fallacy_definition_params
      params.require(:fallacy_definition).permit(:default_enabled, :default_confidence_threshold)
    end
  end
end
