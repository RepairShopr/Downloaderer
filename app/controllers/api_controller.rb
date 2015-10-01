class ApiController < ApplicationController

  def download
    if params[:secret] == "SUPERSECRET123"
      if params[:file_name]
        new_download = {}
        new_download['file_name'] = params[:file_name]
        new_download['date'] = (params[:date] || Time.zone.now.to_date.to_s)
        new_download['url'] = params[:url]

        Rails.cache.write(new_download['file_name'],new_download)
        DownloaderWorker.perform_async(new_download)
        render text: "SUCCESS"
      end
    else
      render text: "NO AUTH."
    end
  end

  def status_check
    if params[:secret] == "SUPERSECRET123"
      report = {}
      report['last_file_size'] = Rails.cache.fetch("last_file_size")
      report['last_file_name'] = Rails.cache.fetch("last_file_name")
      report['last_file_date'] = Rails.cache.fetch("last_file_date")
      report['last_attempt_result'] = Rails.cache.fetch("last_attempt_result")
      render json: report
    else
      render text: "NO AUTH"
    end
  end

end
