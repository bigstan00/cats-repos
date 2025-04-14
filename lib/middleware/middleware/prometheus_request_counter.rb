class PrometheusRequestCounter
  def initialize(app)
    @app = app
    # Ensure metric exists
    register_metric
  end

  private

  def register_metric
    registry = Cats::Metrics.registry
    registry.unregister(:requests_total) rescue nil
    registry.counter(:requests_total, 'Total requests')
  end
end