FROM ruby:2.3.1-alpine


RUN mkdir /usr/app
WORKDIR /usr/app

# project dependencies
ADD Gemfile Gemfile.lock ./
RUN bundle install --deployment --without development:test --jobs 4 --retry 3

ENTRYPOINT ["./main"]

COPY . ./
