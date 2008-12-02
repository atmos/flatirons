class User
  include DataMapper::Resource
 
  property :id, Serial
  property :login,               String, :nullable => false, :unique => true, :unique_index => true
  property :email,               String, :nullable => false, :unique => true, :unique_index => true, :format => :email_address
  property :registration_token,  String, :nullable => true,  :unique => true, :unique_index => true

  def password_required?; !new_record? end 
  
  before :save, :set_defaults
  def set_defaults
    @registration_token = Digest::SHA1.hexdigest("#{email}#{Time.now.to_i}")
    randpass = Digest::SHA1.hexdigest("#{email}#{Time.now.to_i}")
    @password ||= randpass
    @password_confirmation ||= randpass
    true
  end

  def registered?
    registration_token.nil?
  end
end
