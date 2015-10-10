class DownloadNow
  BASE_PATH = "/backups"

  def base_path
    DownloadNow::BASE_PATH
  end

  def download(name,date,url)
    file_name = "#{date}-#{name}"
    full_file_name = "#{base_path}/#{file_name}"
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

  def cleanup_old_files
    number_to_keep = (ENV['NUMBER_TO_KEEP'].presence || 10).to_i
    file_names = Dir["#{base_path}/*"]
    files = []
    file_names.each do |name|
      files << [File.ctime(name),name]
    end
    sorted = sort_by_datetime(files,"DESC")  #this puts newest file in the front of the array
    puts sorted
    to_delete = sorted[number_to_keep..-1].to_a
    to_delete.each do |date_file|
      puts "DELETING: #{date_file[1]}"
      File.delete(date_file[1]) unless date_file[1].include?("lost")
    end
  end

  def sort_by_datetime(dates, direction="ASC")
    dates.sort_by { |date| direction == "DESC" ? -date[0].to_i : date[0] }
  end
end