class User < ActiveRecord::Base
  # TODO "Neighborly::" can be removed after the project rename to "Neighborly"
  has_one :balanced_contributor, class_name: 'Neighborly::Balanced::Creditcard::Contributor'
end
