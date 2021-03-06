require 'shellwords'
require 'chamber/instance'

module  Chamber
module  Commands
module  Securable

  def initialize(options = {})
    super

    ignored_settings_options        = options.
                                        merge(files: ignored_settings_filepaths).
                                        reject { |k, v| k == 'basepath' }
    self.ignored_settings_instance  = Chamber::Instance.new(ignored_settings_options)
    self.all_settings_instance      = Chamber::Instance.new(options)
    self.only_sensitive             = options[:only_sensitive]
  end

  protected

  attr_accessor :only_sensitive,
                :ignored_settings_instance,
                :all_settings_instance

  def securable_environment_variables
    if only_sensitive
      secured_settings.to_environment
    else
      all_settings.to_environment
    end
  end

  def secured_settings
    ignored_settings_instance.settings.merge(all_settings.secured)
  end

  def all_settings
    all_settings_instance.settings
  end

  def ignored_settings_filepaths
    shell_escaped_chamber_filenames = chamber.filenames.map { |filename| Shellwords.escape(filename) }

    `git ls-files --other --ignored --exclude-from=.gitignore | sed -e "s|^|#{Shellwords.escape(rootpath.to_s)}/|" | grep --colour=never -E '#{shell_escaped_chamber_filenames.join('|')}'`.split("\n")
  end
end
end
end
