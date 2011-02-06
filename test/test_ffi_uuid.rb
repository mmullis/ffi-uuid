require 'helper'

class TestFfiUuid < Test::Unit::TestCase
  def test_parse_unparse
    binary_uuid = " " * 16
    FFI::UUID.uuid_generate_random(binary_uuid)
    #puts "binary_uuid: #{binary_uuid.inspect}"
    unparsed_uuid = " " * 36   # 32 hex chars plus 4 dashes
    FFI::UUID.uuid_unparse(binary_uuid, unparsed_uuid)  # unparsed is the formatted hex string
    #puts "unparsed_uuid: #{unparsed_uuid.inspect}"
    parsed_uuid = ' ' * 16
    FFI::UUID.uuid_parse(unparsed_uuid, parsed_uuid)  # parsed is the binary version
    #puts "parsed_uuid: #{parsed_uuid.inspect}"
    assert_equal( binary_uuid, parsed_uuid)
  end

  def test_get_uuid
   unparsed = nil
   sample_uuid = nil
   num_uuids = 100_000
   1.times {
    sample_uuid = FFI::UUID.get_uuids(num_uuids)
    assert sample_uuid.length == num_uuids
    assert sample_uuid.is_a?(Array)
    assert_equal(36, sample_uuid[0].length)

    unparsed = FFI::UUID.unparse(sample_uuid[0])

    assert_equal( 36, unparsed.length)
    assert_equal(unparsed.split(/\-/).length, 5)
    }
  end
end
