# frozen_string_literal: true

# config.ru
require_relative 'cats'  # Assuming your main file is cats.rb
require 'prometheus/middleware/collector'
require 'prometheus/middleware/exporter'
require './cats'  # Ensure this points to your cats.rb file


use Prometheus::Middleware::Collector
use Prometheus::Middleware::Exporter

# This should match your actual application class
# If you're using modular style (recommended):
run Cats::Web

# If you're using classic style:
# run Sinatra::Application