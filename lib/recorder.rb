require "pathname"

module Recorder
  ROOT = Pathname File.expand_path("../..", __FILE__)
  private_constant :ROOT
  # Recorder root pathname
  def self.root
    ROOT
  end

  module Tasks
    # @api private
    def self.install
      # Any default tasks are removed
      Rake::Task[:default].clear if Rake::Task.task_defined?(:default)
      Dir[Recorder.root.join("lib/tasks/*.rake")].each do |rake_file|
        load rake_file
      end

      if Rake::Task.task_defined?(:rubocop)
        Rake::Task.define_task(default: [:rubocop, :spec])
      else
        Rake::Task.define_task(default: [:spec])
      end
    end
  end
  # Define Rake tasks
  Tasks.install if defined?(Rake)
end
