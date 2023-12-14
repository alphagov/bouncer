require "host"
require "mapping"
require "organisation"

class Site < ActiveRecord::Base
  belongs_to :organisation
  has_many :hosts
  has_many :mappings

  def default_hostname
    @default_hostname ||= hosts.where(canonical_host_id: nil).order(:id).first.hostname
  end
end
