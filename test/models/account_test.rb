# frozen_string_literal: true

require 'test_helper'

class AccountTest < ActiveSupport::TestCase
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
