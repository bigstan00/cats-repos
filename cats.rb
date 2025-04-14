# require 'sinatra/base'
# require 'sinatra/json'
# require 'net/http'
# require 'uri'
# require 'prometheus/middleware/collector'
# require 'prometheus/middleware/exporter'
# require 'rack/deflater'
# require "sinatra"



require 'sinatra/base'
require 'sinatra/json'
require 'net/http'
require 'uri'
require 'prometheus/client'
require 'prometheus/middleware/exporter'

module Cats
  class Web < Sinatra::Base
    # Set up Prometheus client registry
    configure do
      set :url, URI('http://thecatapi.com/api/images/get').freeze
      # Initialize Prometheus registry and metrics
      @registry = Prometheus::Client.registry

      # Define metrics correctly using keyword arguments for descriptions
      @login_counter = @registry.counter(:cats_logins_total, docstring: 'Total number of logins')
      @logout_counter = @registry.counter(:cats_logouts_total, docstring: 'Total number of logouts')
      @error_counter = @registry.counter(:cats_errors_total, docstring: 'Total number of errors')
      @active_users_gauge = @registry.gauge(:cats_active_users, docstring: 'Current number of active users')

      # Use Prometheus middleware to export the metrics
      use Prometheus::Middleware::Exporter
    end

    # Health check endpoint
    get '/health' do
      content_type :json
      { status: 'healthy', timestamp: Time.now.to_i }.to_json
    end

    # Root endpoint
    get '/' do
      json url: Net::HTTP.get_response(settings.url)['location']
    end

    # Metric endpoint for Prometheus
    get '/metrics' do
      content_type 'text/plain'
      @registry.metrics.each do |metric|
        # Output each metric in Prometheus format
        metric.collect.each do |sample|
          response.write("# HELP #{sample[:name]} #{sample[:description]}\n")
          response.write("# TYPE #{sample[:name]} #{sample[:type]}\n")
          response.write("#{sample[:name]}{#{sample[:labels].map { |k, v| "#{k}=\"#{v}\"" }.join(',')}} #{sample[:value]}\n")
        end
      end
      response.finish
    end

    # Simulate a login action
    post '/login' do
      @login_counter.increment
      @active_users_gauge.inc
      { message: "Logged in successfully" }.to_json
    end

    # Simulate a logout action
    post '/logout' do
      @logout_counter.increment
      @active_users_gauge.dec
      { message: "Logged out successfully" }.to_json
    end

  end
end
