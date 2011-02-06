require 'rubygems'
require 'ffi'

# uuid_generate_xxx takex uuid_t which is a 16 byte unsigned char
# that is directly updated - treat like a bang! method

class FFI::UUID
  extend FFI::Library

  # load our custom C library and attach
  # FFI functions to our Ruby runtime
  # unfortunately, linux doesnt set libsuid.so
  # MAC OS X Notes:
  #   libSystem.B supports Mac OS X without other packages.
  #   It's useful if libuuid is not installed from a ports or fink package.
  #   libSystem.B is listed last so that a libuuid installed will get picked up first.
  #   To get libuuid picked up, 
  #     export DYLD_FALLBACK_LIBRARY_PATH=<location of libuuid>
  #    e.g
  #      export DYLD_FALLBACK_LIBRARY_PATH=/opt/local/lib:/usr/lib

  ffi_lib(["uuid", "libuuid", "libuuid.so", "libuuid.so.1", "libSystem.B"])

  functions = [
    # method # parameters        # return
    [:uuid_generate_random, [:pointer], :void],
    [:uuid_generate_time,   [:pointer], :void],

    # these are not really necessary and havent' been tested
    [:uuid_generate,        [:pointer], :void],
    #[:uuid_clear, [:string], :void],
    #[:uuid_compare, [:string, :string], :int],
    #[:uuid_copy, [:string, :string], :void],

    #[:uuid_is_null, [:string], :bool],

    # convertion formatted hex string to binary
    [:uuid_parse,   [:pointer, :pointer], :void],

    # convert binary to formatted hex string
    [:uuid_unparse, [:pointer, :pointer], :void],
    [:uuid_unparse_lower, [:pointer, :pointer], :void],
    [:uuid_unparse_upper, [:pointer, :pointer], :void],
  ]

  functions.each do |func|
    begin
      attach_function(*func)
    rescue Object => e
      puts "Could not attach #{func}, #{e.message}"
    end
  end

  def self.generate(algorithm=:random)
    binary_uuid = " " * 16
    formatted_result = " " * 36  # 32 hex chars + 4 dashes
    case algorithm
    when :time
      FFI::UUID.uuid_generate_time(binary_uuid)
    else
      FFI::UUID.uuid_generate_random(binary_uuid)
    end
    ##puts "BINARY_UUID #{binary_uuid.bytes.to_a.inspect}"

    FFI::UUID.uuid_unparse(binary_uuid, formatted_result)
    formatted_result    # manual/slower/ruby way .unpack("H*")[0]
  end

  def self.generate_random
    generate(:random)
  end

  def self.generate_time
    generate(:time)
  end

  def self.unparse(binary_uuid)
    raise "UUID unparsed required non-nil input" if binary_uuid.nil? || binary_uuid.empty?
    formatted_uuid = " " * 36
    FFI::UUID.uuid_unparse(binary_uuid, formatted_uuid)
    formatted_uuid
  end

  # get a set of uuids - useful for server/backend apps that need a lot
  # defaults to the :random algorightm
  # algorithm=:time will switch to the less desirable/secure time based method
  def self.get_uuids(num=1, algorithm=:random)
    uuids = Array.new(num) # preallocate to avoid expansion
    num.times { |i|
      result = case algorithm
      when :time
        generate_time
      else
        generate_random
      end
      uuids[i-1] = result
    }
    uuids
  end
end
