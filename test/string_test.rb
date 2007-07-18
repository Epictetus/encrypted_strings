require File.join(File.dirname(__FILE__), 'test_helper')

class EncryptedStringsTest < Test::Unit::TestCase
  def test_default_encryption
    assert_instance_of PluginAWeek::EncryptedStrings::ShaEncryptor, 'test'.encrypt.encryptor
    
    encrypted_string = 'test'.encrypt(:salt => 'different_salt')
    assert_instance_of PluginAWeek::EncryptedStrings::ShaEncryptor, encrypted_string.encryptor
    assert_equal 'different_salt', encrypted_string.encryptor.salt
  end
  
  def test_encryption_with_mode
    encrypted_string = 'test'.encrypt(:symmetric, :key => 'key')
    assert_instance_of PluginAWeek::EncryptedStrings::SymmetricEncryptor, encrypted_string.encryptor
  end
  
  def test_encryption_replacement
    encrypted_string = 'test'
    encrypted_string.encrypt!
    
    assert !'test'.equals_without_encryption(encrypted_string)
    assert_instance_of PluginAWeek::EncryptedStrings::ShaEncryptor, encrypted_string.encryptor
  end
  
  def test_default_decryption
    encrypted_string = 'test'.encrypt(:symmetric, :key => 'secret')
    assert 'test'.equals_without_encryption(encrypted_string.decrypt)
  end
  
  def test_decryption_with_mode
    assert_equal 'test', "MU6e/5LvhKA=\n".decrypt(:symmetric, :key => 'secret')
  end
  
  def test_decryption_replacement
    encrypted_string = "MU6e/5LvhKA=\n"
    encrypted_string.decrypt!(:symmetric, :key => 'secret')
    
    assert !"MU6e/5LvhKA=\n".equals_without_encryption(encrypted_string)
    assert 'test'.equals_without_encryption(encrypted_string)
  end
  
  def test_equality_with_no_decryption_support
    value = 'test'
    encrypted_string = 'test'.encrypt(:sha)
    encrypted_encrypted_string = encrypted_string.encrypt(:sha)
    
    assert_equal value, encrypted_string
    assert_equal encrypted_string, value
    assert_equal encrypted_string, encrypted_encrypted_string
    assert_equal encrypted_encrypted_string, encrypted_string
    assert_equal encrypted_string.to_s, encrypted_string
    assert_equal encrypted_string, encrypted_string.to_s
    assert_equal encrypted_string, encrypted_string
    
    assert_not_equal value, encrypted_encrypted_string
    assert_not_equal encrypted_encrypted_string, value
  end
  
  def test_equality_with_decryption_support
    PluginAWeek::EncryptedStrings::SymmetricEncryptor.default_key = 'secret'
    
    value = 'test'
    encrypted_string = value.encrypt(:symmetric)
    encrypted_encrypted_string = encrypted_string.encrypt(:symmetric)
    
    assert_equal value, encrypted_string
    assert_equal encrypted_string, value
    assert_equal encrypted_string, encrypted_encrypted_string
    assert_equal encrypted_encrypted_string, encrypted_string
    assert_equal encrypted_string.to_s, encrypted_string
    assert_equal encrypted_string, encrypted_string.to_s
    assert_equal encrypted_string, encrypted_string
    
    assert_not_equal value, encrypted_encrypted_string
    assert_not_equal encrypted_encrypted_string, value
  end
end