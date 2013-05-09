require_relative "./rexpro/version"
require_relative "./rexpro/client"
require_relative "./rexpro/message"

module Rexpro
  class RexproException < StandardError; end
  class RexproError < RexproException; end
end
