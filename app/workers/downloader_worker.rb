class DownloaderWorker
  include Sidekiq::Worker

  sidekiq_options retry: false

  def perform(options={})
    file_name = options['file_name']
    date = options['date']
    url = options['url']
    d = DownloadNow.new
    d.download(file_name,date,url)
    d.cleanup_old_files

  end
end