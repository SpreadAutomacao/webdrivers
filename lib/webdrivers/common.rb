require 'rubygems/package'

module Webdrivers
  class Common

    class << self
      def install *args
        download
        exec binary_path, *args
      end

      def download
        return if File.exists?(binary_path) && !internet_connection?
        raise StandardError, "Unable to Reach #{base_url}" unless internet_connection?
        return if newest_version == current_version

        url = download_url
        filename = File.basename url
        Dir.chdir platform_install_dir do
          FileUtils.rm_f filename
          File.open(filename, "wb") do |saved_file|
            URI.parse(url).open("rb") do |read_file|
              saved_file.write(read_file.read)
            end
          end
          raise "Could not download #{url}" unless File.exists? filename
          decompress_file(filename)
        end
        raise "Could not unzip #{filename} to get #{binary_path}" unless File.exists? binary_path
        FileUtils.chmod "ugo+rx", binary_path
      end

      def download_url(version = nil)
        downloads[version || newest_version]
      end

      def binary_path
        File.join platform_install_dir, file_name
      end

      def platform_install_dir
        File.join(install_dir, platform).tap { |dir| FileUtils.mkdir_p dir }
      end

      def install_dir
        File.expand_path(File.join(ENV['HOME'], ".webdrivers")).tap { |dir| FileUtils.mkdir_p dir}
      end

      def platform
        cfg = RbConfig::CONFIG
        case cfg['host_os']
          when /linux/ then
            cfg['host_cpu'] =~ /x86_64|amd64/ ? "linux64" : "linux32"
          when /darwin/ then "mac"
          else "win"
        end
      end

      def internet_connection?
        true if open(base_url)
      rescue
        false
      end

      def reset
        File.delete binary_path
        gem_name = file_name[/^[^\.]+/]
        File.delete "#{ENV['GEM_HOME']}/bin/#{gem_name}"
      end
    end

  end
end