class Hash
  ### compile_options takes three option arguements and symplifies the use of a hash as part of an options string for a function
  # All keys in the hash are symbolized to reduce conflicts
  # options include:
  #   defaults:
  #     Takes a hash of default options and reverse merges with the exsiting hash
  #   required:
  #     An array of required keys and error is raised if any of theses keys is not present in the hash
  #   asserts:
  #     An array of allowed options, If present all keys in the hash must be included in this array.
  # order of checks are:
  #   1) symbolize_keys
  #   2) merge defaults
  #   3) assert keys: thus any defaults must also be in assert keys if the assert keys feature is used
  #   4) check required: thus default keys are included in the required key checks
  def compile_options(opts = {})
    opts.symbolize_keys!
    opts.assert_valid_keys(:defaults, :required, :asserts)
    opts.reverse_merge!({defaults: {},required: [], asserts: []})

    opts[:required].map!(&:to_sym)
    opts[:asserts].map!(&:to_sym)
    opts[:defaults].symbolize_keys!
    self.symbolize_keys!
    self.reverse_merge!(opts[:defaults])
    self.assert_valid_keys(opts[:asserts]) unless opts[:asserts] == []
    opts[:required].each do |key|
      raise ArgumentError.new("Required key: #{key} not included. Required keys are: #{opts[:required].join(', ')}") unless self.key? key
    end
    self
  end
end
