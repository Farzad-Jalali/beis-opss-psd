require "devise/encryptable/encryptors/base"


# Pbkdf2Encryption.new(password, iterations: self.hash_iterations)
#     self.salt               = e.salt
#     self.encrypted_password = e.generate_hash

 # e = Pbkdf2Encryption.new(password, salt: self.salt)

module Devise
  module Encryptable
    module Encryptors
      class PBKDF2 < Base
        HASH_FUNCTION = OpenSSL::Digest::SHA256.new
        KEY_LEN = 64
        def self.digest(password, stretches, salt, pepper)
          # stretches =
          hashed_password = OpenSSL::KDF.pbkdf2_hmac(
            password,
            salt: salt,
            iterations: 27_500,
            length: KEY_LEN,
            hash: HASH_FUNCTION)

          Base64.strict_encode64(hashed_password).strip
        end
      end
    end
  end
end