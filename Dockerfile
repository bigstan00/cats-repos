# FROM ruby:3.3.0

# # Set working directory
# WORKDIR /code

# # Install specific bundler version first
# RUN gem install bundler -v 2.4.20

# # Copy dependency files first for caching
# COPY Gemfile Gemfile.lock ./

# # Install gems using specific bundler version
# RUN bundle _2.4.20_ install

# # Copy the rest of application
# COPY . .

# EXPOSE 8000

# CMD ["bundle", "_2.4.20_", "exec", "rackup", "--host", "0.0.0.0", "-p", "8000"] 


# Use the official Ruby image
FROM ruby:3.3.0

# Set environment variables
ENV RACK_ENV=production \
    BUNDLE_DEPLOYMENT=true \
    BUNDLE_PATH=/gems

# Set working directory
WORKDIR /code

# Install dependencies
COPY Gemfile Gemfile.lock ./
RUN bundle install

# Copy application files
COPY . .

# Expose the port your app runs on
EXPOSE 8000

# Run the application
CMD ["bundle", "exec", "rackup", "--host", "0.0.0.0", "--port", "8000"]
