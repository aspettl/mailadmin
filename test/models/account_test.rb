# frozen_string_literal: true

require 'test_helper'

class AccountTest < ActiveSupport::TestCase
  setup do
    @postmaster = accounts(:postmaster)
    @mailbox = accounts(:mailbox)
    @alias = accounts(:alias)
    @disabled_alias = accounts(:disabled_alias)
    @drop = accounts(:drop)
  end

  test 'valid fixtures' do
    assert_predicate @postmaster, :valid?, 'postmaster fixture should be valid'
    assert_predicate @mailbox, :valid?, 'mailbox fixture should be valid'
    assert_predicate @alias, :valid?, 'alias fixture should be valid'
    assert_predicate @disabled_alias, :valid?, 'disabled_alias fixture should be valid'
    assert_predicate @drop, :valid?, 'drop fixture should be valid'
  end

  test 'invalid without type' do
    account = Account.new
    account.type = nil

    assert_not account.valid?, 'account object should not be valid'
    assert_includes(account.errors[:type], 'is not included in the list')
  end

  test 'invalid without domain' do
    account = Account.new

    assert_not account.valid?, 'account object should not be valid'
    assert_includes(account.errors[:domain], 'must exist')
  end

  test 'invalid with non-unique email' do
    @mailbox.email = @alias.email

    assert_not @mailbox.valid?, 'account object should not be valid'
    assert_includes(@mailbox.errors[:email], 'has already been taken')
  end

  test 'invalid with non-unique email (case insensitivity required)' do
    @mailbox.email = 'ALIAS@example.com'

    assert_not @mailbox.valid?, 'account object should not be valid'
    assert_includes(@mailbox.errors[:email], 'has already been taken')
  end

  test 'invalid when email not under domain' do
    @mailbox.email = 'mail@subdomain.example.com'

    assert_not @mailbox.valid?, 'account object should not be valid'
    assert_includes(@mailbox.errors[:email], 'must be an account under the currently selected domain name')
  end

  test 'invalid without cleartext password for a new mailbox without crypted password' do
    account = Account.new
    account.valid?

    assert_includes(account.errors[:password], "can't be blank")
  end

  test 'valid without cleartext password for a new mailbox with crypted password' do
    account = Account.new(crypt: '!')
    account.valid?

    assert_empty account.errors[:password]
  end

  test 'valid without cleartext password for a existing mailbox' do
    @mailbox.password = ''
    @mailbox.valid?

    assert_empty @mailbox.errors[:password]
  end

  test 'invalid with short new password' do
    account = Account.new
    account.password = 'short'
    account.valid?

    assert_includes(account.errors[:password], 'is too short (minimum is 10 characters)')
  end

  test 'valid with short but unchanged password' do
    @mailbox.password = 'test'
    @mailbox.valid?

    assert_empty @mailbox.errors[:password]
  end

  test 'invalid with pawned new password' do
    account = Account.new
    account.password = 'testtesttest'
    account.valid?

    assert_includes(account.errors[:password], 'has previously appeared in a data breach and should not be used')
  end

  test 'valid with pawned but unchanged password' do
    @mailbox.password = 'test'
    @mailbox.valid?

    assert_empty @mailbox.errors[:password]
  end

  test 'invalid with cleartext password for an alias address' do
    @alias.password = 'test'
    @alias.valid?

    assert_includes(@alias.errors[:password], 'must be empty when this is not a mailbox')
  end

  test 'invalid with cleartext password for a blackhole address' do
    @drop.password = 'test'
    @drop.valid?

    assert_includes(@drop.errors[:password], 'must be empty when this is not a mailbox')
  end

  test 'valid without forwarding for a mailbox' do
    account = Account.new
    account.forward = false
    account.valid?

    assert_empty account.errors[:forward]
    assert_empty account.errors[:forward_to]
  end

  test 'valid with forwarding and target address for a mailbox' do
    account = Account.new
    account.forward = true
    account.forward_to = 'test@example.com'
    account.valid?

    assert_empty account.errors[:forward]
    assert_empty account.errors[:forward_to]
  end

  test 'invalid with forwarding and missing target address for a mailbox' do
    account = Account.new
    account.forward = true
    account.valid?

    assert_includes(account.errors[:forward_to], "can't be blank")
  end

  test 'invalid with forwarding and invalid target address for a mailbox' do
    account = Account.new
    account.forward = true
    account.forward_to = 'not an email address'
    account.valid?

    assert_includes(account.errors[:forward_to], 'is invalid')
  end

  test 'valid without forwarding but specified target address for a mailbox' do
    account = Account.new
    account.forward = false
    account.forward_to = 'test@example.com'
    account.valid?

    assert_empty account.errors[:forward]
    assert_empty account.errors[:forward_to]
  end

  test 'invalid with forwarding enabled for an alias address' do
    @alias.forward = true
    @alias.forward_to = @alias.alias_target
    @alias.valid?

    assert_includes(@alias.errors[:forward_to], 'must be empty when this is not a mailbox')
  end

  test 'invalid with forwarding enabled for a blackhole address' do
    @drop.forward = true
    @drop.forward_to = @alias.alias_target
    @drop.valid?

    assert_includes(@drop.errors[:forward_to], 'must be empty when this is not a mailbox')
  end

  test 'invalid without target for an alias address' do
    account = Account.new(type: Account.types[:alias_address])
    account.valid?

    assert_includes(account.errors[:alias_target], "can't be blank")
  end

  test 'valid with single email address as target for an alias address' do
    account = Account.new(type: Account.types[:alias_address])
    account.alias_target = 'test@example.com'
    account.valid?

    assert_empty account.errors[:alias_target]
  end

  test 'valid with multiple email addresses as target for an alias address' do
    account = Account.new(type: Account.types[:alias_address])
    account.alias_target = 'test1@example.com,test2@example.com'
    account.valid?

    assert_empty account.errors[:alias_target]
  end

  test 'invalid with self as target for an alias address' do
    account = Account.new(type: Account.types[:alias_address])
    account.email = 'test@example.com'
    account.alias_target = 'test@example.com'
    account.valid?

    assert_includes(account.errors[:alias_target], 'must not redirect to itself')
  end

  test 'invalid with invalid address as target for an alias address' do
    account = Account.new(type: Account.types[:alias_address])
    account.alias_target = 'test'
    account.valid?

    assert_includes(account.errors[:alias_target], 'is invalid')
  end

  test 'invalid with alias target for a mailbox' do
    account = Account.new
    account.alias_target = 'test@example.com'
    account.valid?

    assert_includes(account.errors[:alias_target], 'must be empty when this is not an alias address')
  end

  test 'crypts cleartext password on save (for a new record)' do
    account = Account.new
    account.domain = @mailbox.domain
    account.email = 'new@example.com'
    account.password = SecureRandom.base64(16)
    account.save!

    assert_not_nil account.crypt

    account_from_db = Account.find(account.id)

    assert_nil account_from_db.password
    assert_not_nil account_from_db.crypt
  end

  test 'crypts cleartext password on save (for existing record)' do
    @mailbox.password = SecureRandom.base64(16)
    old_crypt = @mailbox.crypt
    @mailbox.save!

    assert_not_nil @mailbox.crypt
    assert_not_equal old_crypt, @mailbox.crypt
  end

  test 'upgrades hash algorithm to BCRYPT (but does not recrypt when already up-to-date)' do
    assert_not_equal 'BCRYPT', @mailbox.crypt_hash_method

    @mailbox.password = 'test'
    old_crypt = @mailbox.crypt
    @mailbox.save!

    assert_equal 'BCRYPT', @mailbox.crypt_hash_method
    assert_not_equal old_crypt, @mailbox.crypt

    @mailbox.password = 'test'
    old_crypt = @mailbox.crypt
    @mailbox.save!

    assert_equal old_crypt, @mailbox.crypt
  end

  test 'matches_crypted_password? should not validate empty password (none set)' do
    account = Account.new

    assert_not account.matches_crypted_password?('')
  end

  test 'matches_crypted_password? should not validate empty password (empty string set instead of crypt)' do
    account = Account.new(crypt: '')

    assert_not account.matches_crypted_password?('')
  end

  test 'matches_crypted_password? should not validate empty password' do
    account = Account.new(crypt: ''.crypt('aa'))

    assert_not account.matches_crypted_password?('')
  end

  test 'matches_crypted_password? should validate DES passwords' do
    account = Account.new(crypt: 'test'.crypt('aa'))

    assert account.matches_crypted_password?('test')
    assert_not account.matches_crypted_password?('test2')
  end

  test 'matches_crypted_password? should validate MD5 passwords' do
    account = Account.new(crypt: 'test'.crypt('$1$aaaabbbb'))

    assert account.matches_crypted_password?('test')
    assert_not account.matches_crypted_password?('test2')
  end

  test 'matches_crypted_password? should validate SHA-256 passwords' do
    account = Account.new(crypt: 'test'.crypt('$5$aaaabbbbccccdddd'))

    assert account.matches_crypted_password?('test')
    assert_not account.matches_crypted_password?('test2')
  end

  test 'matches_crypted_password? should validate SHA-512 passwords' do
    account = Account.new(crypt: 'test'.crypt('$6$aaaabbbbccccdddd'))

    assert account.matches_crypted_password?('test')
    assert_not account.matches_crypted_password?('test2')
  end

  test 'matches_crypted_password? should validate bcrypt passwords' do
    account = Account.new(crypt: BCrypt::Password.create('test'))

    assert account.matches_crypted_password?('test')
    assert_not account.matches_crypted_password?('test2')
  end

  test 'matches_crypted_password? should validate scrypt passwords' do
    account = Account.new(crypt: '$7$CU..../....r45uDWgDimNmR9jylBJc20$jtIx8GBi6kGLgsWbZ7cB0iv0SwiJFJwSS9QdiMX.bWB')

    assert account.matches_crypted_password?('test')
    assert_not account.matches_crypted_password?('test2')
  end

  test 'matches_crypted_password? should validate yescrypt passwords' do
    account = Account.new(crypt: '$y$j9T$JFwAauauD7qiqayNAniPa/$S1I7nNhDdmV8m8M0pGBD6OFyWq3UjUa5tohkCQ70ra5')

    assert account.matches_crypted_password?('test')
    assert_not account.matches_crypted_password?('test2')
  end
end
