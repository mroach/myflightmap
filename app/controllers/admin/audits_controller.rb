module Admin
  class AuditsController < AdminController
    include Audited::Adapters::ActiveRecord

    # GET /audits/:type/:id
    # Ex) /audits/flight/845.json
    #     /audits/trip/71.json
    def index
      @audits = Audit.where("auditable_id = ? AND LOWER(auditable_type) = LOWER(?)", params[:id], params[:type])
    end
  end
end
