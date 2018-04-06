FROM ruby:2.4.3

# Add PPA for PostgreSQL
RUN curl -sS https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - \
 && echo "deb http://apt.postgresql.org/pub/repos/apt/ jessie-pgdg main" | tee /etc/apt/sources.list.d/pgdg.list

# Add PPA for Chrome
RUN curl -sS https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
 && echo "deb http://dl.google.com/linux/chrome/deb/ stable main"  | tee /etc/apt/sources.list.d/google.list

RUN apt-get update && apt-get install -qq -y \
    # Ensure we can build gems with C extensions
    build-essential \
    # Add build dependencies for nokogiri
    libxml2-dev \
    # NodeJS is needed to compile Rails assets
    nodejs \
    # PostgreSQL native extensions for pg gem
    libpq-dev \
    # PostgreSQL client for connecting to server
    postgresql-client-9.6 \
    # For capybara tests with Chrome headless
    google-chrome-stable \
    # And don't install more than what we need, but fix missing packages
    --fix-missing --no-install-recommends

WORKDIR /app

# Install gems
# Ensure they are only reinstalled when gemfiles changes
RUN gem install bundler -v 1.16.1
COPY Gemfile Gemfile
COPY Gemfile.lock Gemfile.lock
RUN bundle install

# Copy the rest of the application
COPY . .

CMD ["rails", "server", "--binding=0.0.0.0", "--pid=/tmp/app.pid"]

RUN useradd -m developer \
 && chown -R developer:developer $GEM_HOME \
 && chown -R developer:developer .

USER developer
