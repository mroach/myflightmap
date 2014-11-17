module Admin
  class AuditsController < AdminController
    include Audited::Adapters::ActiveRecord

    before_action :validate_type

    # GET /audits/:type/:id
    # Ex) /audits/flight/845.json
    #     /audits/trip/71.json
    def index
      @audits = Audit.where("auditable_id = ? AND LOWER(auditable_type) = LOWER(?)", params[:id], params[:type])
    end

    private

    def validate_type
      # Throw an exception if the given model name isn't valid
      type = params[:type].downcase
      models = audited_types.map(&:downcase)
      raise "Unknown audit type '#{type}'" unless models.include?(type)
    end

    def audited_types
      # Load all files unless the app is configured to do so already (as in production)
      Rails.application.eager_load! unless Rails.application.config.eager_load

      # find audited types by looking for the audited methods in ActiveRecord classes
      ActiveRecord::Base.descendants.select do |d|
        d.include?(Audited::Auditor::AuditedInstanceMethods)
      end.map(&:name)
    end
  end
end
