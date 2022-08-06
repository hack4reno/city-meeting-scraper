# City Government Agenda Scraper

This scraper is designed to pull down meetings from iqm2 hosted agenda and meeting minutes.

## Getting Started
Using rvm or rbenv make sure you have the ruby version defined in .ruby-version.

### Install the gems
```
bundle install
```

### Setup a .env

Create a `.env` file based on the `sample.env`.

The `CITY_PORTAL_URL` should be the iqm2 portal calendar URL.

```
# Example for the City of Reno IQM2 portal with dates from 1/1/1900 to 12/31/9999
CITY_PORTAL_URL="http://renocitynv.iqm2.com/Citizens/calendar.aspx?From=1/1/1900&To=12/31/9999"
```

### Run the test scraper

```
ruby scraper.rb
```