module SpotlightSearch
  class ExportJobsController < ApplicationController
    def export_job
      begin
        klass = params[:class_name].constantize
        if klass.validate_exportable_columns(params[:columns])
          ExportJob.perform_later(klass.name, params[:email], params[:columns], params[:filters], params[:sort])
          notice = 'Successfully queued for export'
        else
          notice = 'Invalid columns found'
        end
      rescue StandardError => e
        notice = e.message
      ensure
        redirect_back fallback_location: root_path, notice: notice
      end
    end
  end
end
