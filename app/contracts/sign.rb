# frozen_string_literal: true

module Contracts
  class Sign < Dry::Validation::Contract
    schema do
      required(:text).value(:string)
    end
  end
end
