module Cats
  module Metrics
    @mutex = Mutex.new

    def self.reset_registry
      @mutex.synchronize do
        @registry = nil
        @metrics_initialized = false
      end
    end

    def self.registry
      @registry ||= @mutex.synchronize do
        reg = Prometheus::Client.registry
        register_metrics(reg) unless @metrics_initialized
        reg
      end
    end

    def self.register_metrics(reg)
      @mutex.synchronize do
        return if @metrics_initialized

        # Define all metrics
        reg.counter(
          :http_requests_total,
          docstring: 'Total HTTP requests',
          labels: %i[method path status],
          preset_labels: { app: 'cats' }
        )

        reg.histogram(
          :http_response_time_seconds,
          docstring: 'Response time histogram',
          labels: %i[method path],
          buckets: [0.1, 0.5, 1, 2, 5, 10]
        )

        reg.gauge(
          :logged_in_users,
          docstring: 'Currently logged in users',
          labels: %i[environment]
        )

        reg.histogram(
          :api_data_latency_seconds,
          docstring: 'API data fetching latency',
          buckets: [0.1, 0.3, 0.5, 1, 2, 5]
        )

        @metrics_initialized = true
      end
    end

    # Thread-safe metric accessors
    def self.request_counter
      registry.get(:http_requests_total)
    end

    def self.response_time
      registry.get(:http_response_time_seconds)
    end

    def self.logged_in_users
      registry.get(:logged_in_users)
    end

    def self.api_data_latency
      registry.get(:api_data_latency_seconds)
    end
  end
end