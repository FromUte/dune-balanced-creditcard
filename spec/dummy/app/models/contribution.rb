# Dummy class to be stubbed
class Contribution
  def self.find(id)
    new
  end

  def update_attributes(*); end

  def id(*)
    42
  end

  def price_in_cents(*)
    50
  end

  def project
    @project ||= Project.new
  end
end
