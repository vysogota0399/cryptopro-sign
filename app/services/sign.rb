# frozen_string_literal: true

module Services
  class Sign
    include Dry::Monads[:result, :do]
    include Import['logger', 'settings']
  
    def call(message)
      file_with_message = yield write_message_to_file(Base64.urlsafe_decode64(message))
      signature = yield create_signature(file_with_message)
      Success(signature)
    ensure
      unlink(file_with_message)
    end
  
    private
  
    def write_message_to_file(message)
      file = Tempfile.open('signature', 'tmp')
      file.write(message)
      file.close
      Success(file)
    rescue StandardError => e
      logger.error('Sign failed [write_data_to_file]', e)
      Failure('sign_failed')
    end
  
    def create_signature(file_with_message)
      signature_filename = "#{file_with_message.path}.sgn"
      command = %Q(csptest -keys -cont '#{container_name}' -sign #{sign_alg} -in #{file_with_message.path} -out #{signature_filename} -keytype exchange -password #{password})
      logger.debug { command }
      sign_message, status = Open3.capture2(command)
      unless status.success?
        logger.error { "Sign failed [create_signature]: #{sign_message}" }
        return Failure('sign_failed')
      end
  
      signature_file = File.open(signature_filename, 'rb')
      signature_bytes = signature_file.read.reverse
      signature_base64 = Base64.urlsafe_encode64(signature_bytes, padding: false)
      File.delete(signature_file)
      Success(signature_base64)
    end
  
    def unlink(file)
      logger.debug { 'delete file' }
      file.unlink
    end
  
    def sign_alg = settings.sign_alg
  
    def container_name = settings.container_name
  
    def password = settings.container_password
  end
end
