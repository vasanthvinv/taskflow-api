class JwtService
  SECRET = Rails.application.secret_key_base

  def self.encode(payload)
    payload[:exp] = 7.days.from_now.to_i
    JWT.encode(payload, SECRET, 'HS256')
  end

  def self.decode(token)
    decoded = JWT.decode(token, SECRET, true, algorithm: 'HS256')
    HashWithIndifferentAccess.new(decoded[0])
  rescue JWT::DecodeError
    nil
  end
end
