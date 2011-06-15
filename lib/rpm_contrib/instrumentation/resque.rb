module Resque
  module Plugins
    module NewRelicInstrumentation
      include NewRelic::Agent::Instrumentation::ControllerInstrumentation

      def around_perform_with_monitoring(*args)
        perform_action_with_newrelic_trace(:name => 'perform', :class_name => to_s, :category => 'OtherTransaction/ResqueJob') do
          yield(*args)
        end

        NewRelic::Agent.shutdown
      end
    end
  end
end

module RPMContrib
  module Instrumentation
    module Resque
      ::Resque.before_first_fork do
        NewRelic::Agent.manual_start(:dispatcher => :resque)
      end

      ::Resque.after_fork do
        NewRelic::Agent.after_fork(:force_reconnect => false)
      end

      ::Resque::Job.class_eval do
        extend ::Resque::Plugins::NewRelicInstrumentation
      end
    end
  end
end if defined?(::Resque) and not NewRelic::Control.instance['disable_resque']
