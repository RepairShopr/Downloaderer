class DownloadNow

  def download(name,date,url)
    base_path = "/backups/"
    file_name = "#{date}-#{name}"
    full_file_name = "#{base_path}#{file_name}"
    command = "wget -O #{full_file_name} '#{url}'"
    system command
    if File.exist?(full_file_name)
      puts "Yay, file was saved.."
      size = File.size?(full_file_name)
      puts "File Size: #{size}"
      if size > 0
        size = size/1024.0/1000.0
      end
      Rails.cache.write("last_file_size","#{size} MB")
      Rails.cache.write("last_file_name",full_file_name)
      Rails.cache.write("last_file_date",Time.zone.now.to_s)
      Rails.cache.write("last_attempt_result","success")
    else
      puts "File did not save - uhoh"
      Rails.cache.write("last_attempt_result","error")
    end
  end
end