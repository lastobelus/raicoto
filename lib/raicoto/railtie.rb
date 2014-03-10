# encoding: UTF-8

module Raicoto
  class Railtie < Rails::Railtie
    console do
      require 'raicoto/activerecord/inspection'
    end
  end
end