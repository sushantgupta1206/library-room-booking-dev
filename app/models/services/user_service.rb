# Service class for user CRUD operations

class UserService

  # Create an admin object. Enforce uniqueness of emailId
  def UserService.create_admin(emailId, fname, lname, pw, confirm_pw)
    if (User.find_by(emailId: emailId))
      return nil
    end
    if (pw == confirm_pw)
      user = User.new(password: pw, password_confirmation: confirm_pw)
      user.emailId = emailId;
      user.first_name = fname
      user.last_name = lname
      user.is_preconfigured = false;
      user.is_admin = true
      user.save
      user
    end
  end

  # Create a library user. Enforce uniqueness of emailId
  def UserService.create_library_user(emailId, fname,  lname, pw, confirm_pw)
    if (User.find_by(emailId: emailId))
      return nil
    end
    # User uses secure password and bcrypt. Both passwd and confirm passwd needed
    # Encrypted passwd stored in the DB
    if (pw == confirm_pw)
      user = User.new(password: pw, password_confirmation: confirm_pw)
      user.emailId = emailId;
      user.first_name = fname
      user.last_name = lname
      user.is_preconfigured = false;
      user.is_admin = false
      user.save
      user
    end
  end

  def UserService.change_password(id,pw,confirm_pw)
    user = User.find_by(emailId:id)
    if (user != nil)
      user.password = pw
      user.password_confirmation = confirm_pw
      user.save
    end
  end

  def UserService.change_name(id, fname, lname)
    user = User.find_by(emailId:id)
    if (user != nil)
      user.first_name = fname
      user.last_name = lname
      user.save
    end
  end

  # User object uses secure password and bcrypt gem
  # Authentication checks equality of encrypted passwd
  def UserService.authenticate(id, pw)
    return false if User.find_by(emailId:id) == nil
    if User.find_by(emailId:id).try(:authenticate, pw) == false
      return false
    end
    return true
  end

  def UserService.is_admin(id)
    user = User.find_by(emailId: id)
    if (user != nil)
      return user.is_admin
    end
    return false
  end

  def UserService.is_library_user(id)
    return !UserService.is_admin(id)
  end

  def UserService.all_library_users()
    return User.where('is_admin = false')
  end

  def UserService.all_admin_users()
    return User.where ('is_admin = true')
  end

  def UserService.delete_user(user)
    if (!user.is_preconfigured)
      User.destroy(user.id)  # Consider soft-delete
    end
  end

  def UserService.find_user(email)
    User.find_by(emailId: email)
  end
end

