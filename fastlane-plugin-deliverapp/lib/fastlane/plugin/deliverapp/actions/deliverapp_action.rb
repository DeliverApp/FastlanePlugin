require 'fastlane/action'
require 'apktools/apkxml'
require 'cfpropertylist'
require 'zip'
require_relative '../helper/deliverapp_helper'

module Fastlane
  module Actions
    class DeliverappAction < Action
      def self.run(params)
        # Get APK path
        binary = params[:binary]
        binary_version = ""
        binary_bundleId = ""

        unless File.exist?(binary)
          UI.user_error!("APK file not found at #{binary}")
        end

        if binary.end_with?('.apk')
          UI.message("Detected an Android APK")
          # Parse APK version and bundleID
          xml = ApkXml.new(binary)
          manifest_xml = xml.parse_xml("AndroidManifest.xml", true, true)
          binary_version = manifest_xml.match(/android:versionName="(.*?)"/)[1]
          binary_number = Integer(manifest_xml.match(/android:versionCode="(.*?)"/)[1]).to_s
          binary_bundleId = manifest_xml.match(/package="(.*?)"/)[1]
        elsif binary.end_with?('.ipa')
          UI.message("Detected an iOS IPA")
          Zip::File.open(binary) do |zip_file|
            # Parse IPA version and bundleID
            info_plist_entry = zip_file.glob('Payload/*.app/Info.plist').first
            zip_file.extract(info_plist_entry, "./info.plist") unless File.exist?("./info.plist")
            
            plist = CFPropertyList::List.new(:file => "./info.plist")
            data = CFPropertyList.native_types(plist.value)
            
            binary_version = data['CFBundleShortVersionString']
            binary_number = data['CFBundleVersion']
            binary_bundleId = data['CFBundleIdentifier']
          end
        else
          UI.error("Unknown binary type. Please provide a valid APK or IPA file.")
        end

        default_git_commit_message = Actions.sh("git log -1 --pretty=%B").strip
        default_git_commit_hash = Actions.sh("git rev-parse --short HEAD").strip
        default_git_committer_email = Actions.sh("git log -1 --pretty=%ae").strip
        default_git_branch_name = Actions.sh("git rev-parse --abbrev-ref HEAD").strip

        # Gather Git metadata
        commit_message = ENV['CI_COMMIT_MESSAGE'] || default_git_commit_message || params[:commit_message] ||  "Not found"
        commit_hash = ENV['CI_COMMIT_SHORT_SHA'] || default_git_commit_hash  || params[:commit_hash] ||  "Not found"
        committer_email = ENV['GITLAB_USER_EMAIL'] || default_git_committer_email  || params[:committer_email] ||  "Not found"
        branch_name = ENV['CI_COMMIT_BRANCH'] || default_git_branch_name  || params[:branch_name] ||  "Not found"
        pipeline_identifier = ENV['CI_PIPELINE_ID'] || params[:pipeline_identifier] ||  "Not found"

        regex = /(?:\s|^)([A-Z]+-[0-9]+)(?=\s|$)?/
        issue_id = commit_message.match(regex)

        if issue_id
            issue_id = issue_id[0]
        else
            issue_id = "No related issue"
        end

        # Send APK and metadata to server
        serverURL = "https://store.deliverapp.io/api/app/" + params[:appKey] + "/" + binary_bundleId +"/build"
        UI.success(serverURL)
        uri = URI.parse(serverURL)
       
        http = Net::HTTP.new(uri.host, uri.port);
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_PEER # Verify the SSL certificate
        request = Net::HTTP::Post.new(uri)
        form_data = [
            ['appId', params[:appKey]],
            ['version', binary_version],
            ['buildNumber', binary_number],
            ['file', File.open(binary)],
            ['branch', branch_name],
            ['commitHash', commit_hash],
            ['commitMessage', commit_message],
            ['pipelineId', pipeline_identifier],
            ['committerEmail', committer_email],
            ['customerIssue', issue_id]
        ]

        puts form_data.inspect
        request.set_form form_data, 'multipart/form-data'
        response = http.request(request)
        puts response.read_body

        if response.code.to_i == 201
          UI.success("Binary successfully published to server!")
        else
          UI.user_error!("Failed to upload Binary: #{response.body}")
        end
      end

      def self.description
        "'Publish your build to https://store.deliverapp.io/ with several usefull informations'"
      end

      def self.authors
        ["Deliver"]
      end

      def self.return_value
        # If your method provides a return value, you can describe here what it does
      end

      def self.details
        # Optional:
        "'For more informations, send us an email at contact@deliverapp.io'"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :binary,
                    description: "Path to the APK file",
                    optional: false,
                    type: String),
          FastlaneCore::ConfigItem.new(key: :appKey,
                    description: "The application Key",
                    optional: false,
                    type: String),
          FastlaneCore::ConfigItem.new(key: :bundleId,
                    description: "The application bundleId",
                    optional: true,
                    type: String),
          FastlaneCore::ConfigItem.new(key: :pipeline_identifier,
                    description: "The pipeline identifier",
                    optional: true,
                    type: String),
          FastlaneCore::ConfigItem.new(key: :commit_message,
                    description: "The commit message",
                    optional: true,
                    type: String),
          FastlaneCore::ConfigItem.new(key: :commit_hash,
                    description: "The commit hash",
                    optional: true,
                    type: String),
          FastlaneCore::ConfigItem.new(key: :committer_email,
                    description: "The committer email",
                    optional: true,
                    type: String),
          FastlaneCore::ConfigItem.new(key: :branch_name,
                    description: "The branch name",
                    optional: true,
                    type: String)
        ]
      end

      def self.is_supported?(platform)
        # Adjust this if your plugin only works for a particular platform (iOS vs. Android, for example)
        # See: https://docs.fastlane.tools/advanced/#control-configuration-by-lane-and-by-platform
        #
        # [:ios, :mac, :android].include?(platform)
        true
      end
    end
  end
end
