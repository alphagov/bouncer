Raven.configure do |config|
  # In staging and integration we often see tens of thousands `PG::ConnectionBad`
  # errors a day during data syncs. This is eating up our Sentry quota.
  config.excluded_exceptions << "PG::ConnectionBad"
end
