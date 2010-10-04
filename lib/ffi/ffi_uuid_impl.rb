require 'rubygems'
require 'ffi'

# uuid_generate_xxx take uuid_t which is a 16 byte unsigned char
# that is directly updated - treat like a bang! method

class FFI::UUID
  extend FFI::Library
 
  # load our custom C library and attach
  # FFI functions to our Ruby runtime
  ffi_lib "libuuid"
 
  functions = [
    # method # parameters        # return
    [:uuid_generate_random, [:string], :void],
    [:uuid_generate_time,   [:string], :void],

    # these are not really necessary and havent' been tested
    #[:uuid_generate,        [:string], :void],
    #[:uuid_clear, [:string], :void],
    #[:uuid_compare, [:string, :string], :int],
    #[:uuid_copy, [:string, :string], :void],

    #[:uuid_is_null, [:string], :bool],
    #[:uuid_parse,   [:string, :string], :void],

    #[:uuid_unparse, [:string, :string], :void],
    #[:uuid_unparse_lower, [:string, :string], :void],
    #[:uuid_unparse_upper, [:string, :string], :void],
  ]
 
  functions.each do |func|
    begin
      attach_function(*func)
    rescue Object => e
      puts "Could not attach #{func}, #{e.message}"
    end
  end

  # get a set of uuids - useful for server/backend apps that need a lot
  # defaults to the :random algorightm
  # algorithm=:time will switch to the less desirable/secure time based method
  def self.get_uuids(num=1, algorithm=:random)
    uuids = Array.new(num) # preallocate to avoid expansion 
    num.times { |i|
      result = ' ' * 16  # allocate 16 bytes for uuid_t
      case algorithm
      when :time
        FFI::UUID.uuid_generate_time(result)
      else
        FFI::UUID.uuid_generate_random(result)
      end      
      uuids[i-1] = (result.unpack("H*")[0])
    }
    uuids
  end
end

