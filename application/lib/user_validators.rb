class UserCreateValidator
  include Hanami::Validations

  validations do
    required('first_name') { filled? & str? & size?(2..64) }
    required('last_name') { filled? & str? & size?(2..64) }
    required('password') { filled? & str? & size?(64) }
    required('email') { filled? & str? & size?(8..64) }
    optional('born_on') { filled? & date? }
  end
end

class UserUpdateValidator
  include Hanami::Validations

  validations do
    optional('first_name') { filled? & str? }
    optional('last_name') { filled? & str? }
    optional('email') { filled? & str? }
  end
end

class UserPasswordUpdateValidator
  include Hanami::Validations

  validations do
    required(:new_password).filled.confirmation
  end
end
