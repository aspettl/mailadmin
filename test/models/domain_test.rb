# frozen_string_literal: true

require 'test_helper'

class DomainTest < ActiveSupport::TestCase
  setup do
    @local_domain = domains(:examplecom)
    @catchall_domain = domains(:exampleorg)
    @alias_domain = domains(:examplenet)
  end

  test 'valid fixtures' do
    assert @local_domain.valid?, 'examplecom fixture should be valid'
    assert @catchall_domain.valid?, 'exampleorg fixture should be valid'
    assert @alias_domain.valid?, 'examplenet fixture should be valid'
  end

  test 'invalid without type' do
    @local_domain.type = nil
    assert_not @local_domain.valid?, 'domain object should not be valid'
    assert_includes(@local_domain.errors[:type], 'is not included in the list')
  end

  test 'invalid without user' do
    @local_domain.user = nil
    assert_not @local_domain.valid?, 'domain object should not be valid'
    assert_includes(@local_domain.errors[:user], 'must exist')
  end

  test 'invalid without domain name' do
    @local_domain.domain = nil
    assert_not @local_domain.valid?, 'domain object should not be valid'
    assert_includes(@local_domain.errors[:domain], 'is invalid')
  end

  test 'invalid with empty domain name' do
    @local_domain.domain = ''
    assert_not @local_domain.valid?, 'domain object should not be valid'
    assert_includes(@local_domain.errors[:domain], 'is invalid')
  end

  test 'invalid with incomplete domain name' do
    @local_domain.domain = 'test'
    assert_not @local_domain.valid?, 'domain object should not be valid'
    assert_includes(@local_domain.errors[:domain], 'is invalid')
  end

  test 'invalid with spaces in domain name' do
    @local_domain.domain = 'test test.de'
    assert_not @local_domain.valid?, 'domain object should not be valid'
    assert_includes(@local_domain.errors[:domain], 'is invalid')
  end

  test 'invalid with special characters in domain name' do
    @local_domain.domain = 'test+test.de'
    assert_not @local_domain.valid?, 'domain object should not be valid'
    assert_includes(@local_domain.errors[:domain], 'is invalid')
  end

  test 'invalid with extra-long TLD in domain name' do
    @local_domain.domain = 'test.superlongtld'
    assert_not @local_domain.valid?, 'domain object should not be valid'
    assert_includes(@local_domain.errors[:domain], 'is invalid')
  end

  test 'invalid with multi-line domain name' do
    @local_domain.domain = "test.de\ntest.com"
    assert_not @local_domain.valid?, 'domain object should not be valid'
    assert_includes(@local_domain.errors[:domain], 'is invalid')
  end

  test 'invalid with extra long domain name' do
    @local_domain.domain = "#{'a' * 255}.com"
    assert_not @local_domain.valid?, 'domain object should not be valid'
    assert_includes(@local_domain.errors[:domain], 'is too long (maximum is 255 characters)')
  end

  test 'invalid with non-unique domain name' do
    @local_domain.domain = @alias_domain.domain
    assert_not @local_domain.valid?, 'domain object should not be valid'
    assert_includes(@local_domain.errors[:domain], 'has already been taken')
  end

  test 'invalid with non-unique domain name (case insensitivity required)' do
    @local_domain.domain = @alias_domain.domain
    assert_not @local_domain.valid?, 'domain object should not be valid'
    assert_includes(@local_domain.errors[:domain], 'has already been taken')
  end

  test 'invalid with domain being a subdomain of another user' do
    domain = Domain.new(domain: 'test.example.com')
    domain.user = users(:quentin)
    assert_not domain.valid?, 'domain object should not be valid'
    assert_includes(domain.errors[:domain], "is a subdomain of already existing 'example.com' from a different user")
  end

  test 'valid existing domain even when it is a subdomain of another user' do
    domain = Domain.new(domain: 'test.example.com')
    domain.type = Domain.types[:local_domain]
    domain.user = users(:quentin)
    domain.enabled = true
    domain.save(validate: false)
    assert domain.valid?, 'subdomain user check should only be performed on create'
  end

  test 'invalid with catchall but without target' do
    @local_domain.catchall = true
    assert_not @local_domain.valid?, 'domain object should not be valid'
    assert_includes(@local_domain.errors[:catchall_target], "can't be blank")
  end

  test 'valid with catchall target but without catchall active' do
    @local_domain.catchall_target = 'mail@test.xy'
    assert @local_domain.valid?
  end

  test 'invalid with catchall target being empty' do
    @catchall_domain.catchall_target = ''
    assert_not @catchall_domain.valid?, 'domain object should not be valid'
    assert_includes(@catchall_domain.errors[:catchall_target], "can't be blank")
  end

  test 'invalid with catchall target not being an email address' do
    @catchall_domain.catchall_target = 'invalid email address'
    assert_not @catchall_domain.valid?, 'domain object should not be valid'
    assert_includes(@catchall_domain.errors[:catchall_target], 'is invalid')
  end

  test 'invalid with catchall target not being a domain' do
    @alias_domain.catchall_target = 'mail@test.xy'
    assert_not @alias_domain.valid?, 'domain object should not be valid'
    assert_includes(@alias_domain.errors[:catchall_target], 'must be empty when this is an alias domain')
  end

  test 'invalid with alias target being empty' do
    @alias_domain.alias_target = ''
    assert_not @alias_domain.valid?, 'domain object should not be valid'
    assert_includes(@alias_domain.errors[:alias_target], 'is invalid')
  end

  test 'invalid with alias target not being a domain' do
    @alias_domain.alias_target = 'invalid'
    assert_not @alias_domain.valid?, 'domain object should not be valid'
    assert_includes(@alias_domain.errors[:alias_target], 'is invalid')
  end

  test 'invalid with alias target on non-alias type' do
    @local_domain.alias_target = 'test.xy'
    assert_not @local_domain.valid?, 'domain object should not be valid'
    assert_includes(@local_domain.errors[:alias_target], 'must be empty when this is not an alias domain')
  end
end
