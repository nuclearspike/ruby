# ghcr.io/nuclearspike/ruby-timelocal — Ruby 3.3.10 + time.c local-time optimization
# (find_time_t offset seed + probe dedup; see nuclearspike/ruby tag v3_3_10-timelocal.1).
# Built for the heroku-26 stack; consumed by app Dockerfiles as their runtime interpreter.
FROM heroku/heroku:26-build AS build
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update -qq && apt-get install -y -qq autoconf rustc libssl-dev libyaml-dev zlib1g-dev libgmp-dev libffi-dev libreadline-dev git && rm -rf /var/lib/apt/lists/*
RUN git clone --depth 1 --branch v3_3_10-timelocal.1 https://github.com/nuclearspike/ruby.git /ruby-src
WORKDIR /ruby-src
RUN ./autogen.sh && ./configure --prefix=/app/ruby-timelocal --enable-yjit --disable-install-doc --enable-shared && make -j"$(nproc)" && make install
# sanity: interpreter must self-report 3.3.10 (Gemfile pin) and pass a conversion smoke
RUN /app/ruby-timelocal/bin/ruby -e 'abort "version" unless RUBY_VERSION == "3.3.10"; t = Time.local(2026, 8, 7, 12, 30, 45); abort "conv" unless t.hour == 12'

FROM heroku/heroku:26
COPY --from=build /app/ruby-timelocal /app/ruby-timelocal
ENV PATH=/app/ruby-timelocal/bin:$PATH
RUN ruby -v && gem -v && bundle -v
