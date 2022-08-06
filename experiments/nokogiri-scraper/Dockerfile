FROM ruby:2.7-alpine

RUN set -ex && \
  apk add --no-cache gcc musl-dev make

# throw errors if Gemfile has been modified since Gemfile.lock
# RUN bundle config --global frozen 1

WORKDIR /usr/src/app

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY . .

# CMD ["ruby scraper.rb"]
