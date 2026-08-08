# ruby-timelocal base image

Ruby 3.3.10 with the local-time conversion optimization (`find_time_t` offset seeding + redundant-probe
elimination), built for the heroku-26 stack. Source: branch `lssd/time-local-3.3`, immutable tag
`v3_3_10-timelocal.1` in this repo. Validation: byte-parity across 599 macOS + 499 Linux tzdata zones,
full upstream time suites green, application test suites byte-identical vs stock 3.3.10.

Image: `ghcr.io/nuclearspike/ruby-timelocal:3.3.10-timelocal.1` (linux/amd64).
Reports `RUBY_VERSION == "3.3.10"`, so `ruby '3.3.10'` Gemfile pins are satisfied.
