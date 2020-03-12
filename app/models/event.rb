class Event < ApplicationRecord
  has_many :event_users
  reverse_geocoded_by :lat, :long
  after_validation :geocode, if: :will_save_change_to_address?
end
