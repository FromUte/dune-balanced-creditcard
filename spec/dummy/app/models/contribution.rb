# Dummy class to be stubbed
class Contribution
  def self.find(id)
    new
  end

  def id(*)
    42
  end

  def project
    @project ||= Project.new
  end
end
