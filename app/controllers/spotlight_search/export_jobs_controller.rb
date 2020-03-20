module SpotlightSearch
  class ExportJobsController < ApplicationController
    def export_job
      begin
        klass = params[:class_name].constantize
        if klass.validate_exportable_columns(params[:columns])
          ExportJob.perform_later(klass, params[:email], params[:columns], params[:filters], params[:sort])
          flash[:success] = 'Successfully queued for export'
        else
          flash[:error] = 'Invalid columns found'
        end
      rescue
        flash[:error] = 'No records to import'
      ensure
        redirect_back fallback_location: root_path
      end
    end
  end
end
