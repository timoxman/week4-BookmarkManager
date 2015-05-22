# bcrypt will generate the password hash
require 'bcrypt'

class User

  include DataMapper::Resource

  property :id, Serial
  property :email, String, unique: true, message: 'This email is already taken'  #unique creates an index on this attribute

  # this will store both the password and the salt
  # It's Text and not String because String holds
  # 50 characters by default and it's not enough for the hash and salt
  property :password_digest, Text

  # this is datamapper's method of validating the model.
  # The model will not be saved unless both password
  # and password_confirmation are the same
  # read more about it in the documentation
  # http://datamapper.org/docs/validations.html
  validates_confirmation_of :password, :message => "Sorry, your passwords do not match"

  attr_reader :password
  attr_accessor :password_confirmation
  # these feilds are not stored to the database (only the digest of the password is stored) therefore these fields can be created as instance variables when required. the Attr_accesssor also just creates them when required as well on the fly.



  # when assigned the password, we don't store it directly
  # instead, we generate a password digest, that looks like this:
  # "$2a$10$vI8aWBnW3fID.ZQ4/zo1G.q1lRps.9cGLcZEiGDMVr5yUP1KUOYTa"
  # and save it in the database. This digest, provided by bcrypt,
  # has both the password hash and the salt. We save it to the
  # database instead of the plain password for security reasons.
  def password=(password)
    @password = password
    self.password_digest = BCrypt::Password.create(password)
  end

  # pass password + salt =into bcrypt> get out the digest hash.

  #This is a one way encrption, when we get password again, we can use the same salt, create hash again then decide if the digests match each other or not to allow the user into the site. (salt is hidden from us)


  def self.authenticate(email, password)
    # that's the user who is trying to sign in
    user = first(email: email)
    # if this user exists and the password provided matches
    # the one we have password_digest for, everything's fine
    #
    # The Password.new returns an object that overrides the ==
    # method. Instead of comparing two passwords directly
    # (which is impossible because we only have a one-way hash)
    # the == method calculates the candidate password_digest from
    # the password given and compares it to the password_digest
    # it was initialised with.
    # So, to recap: THIS IS NOT A STRING COMPARISON
    if user && BCrypt::Password.new(user.password_digest) == password
      # return this user
      user
    else
      nil
  end
  end

end