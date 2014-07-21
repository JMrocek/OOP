require 'rspec'

ROLES = {owner: 0, admin: 1, user: 3}

class User < Struct.new(:name)
  def can_view?(a)
    a.is_member?(self)
  end




end

class Account

  def initialize(name, members)
    @name = name
    raise(ArgumentError) unless members.has_value?(:owner)
    @members = members
  end


  def is_owner?(u)
    @owner == u
  end

  def add_member(u)
    add_member_with_role(u, :user)
    #Account.new(@name, @members.merge({u => :user}))
  end

  def add_member_with_role(u, r)
    Account.new(@name, @members.merge({u => r}))
  end

  def is_member?(u)
    @members.include?(u)
  end



  def list_users(user)
    result = {}
    @members.each do |(u, r)|
      can_edit = ROLES[@members[user]] <= ROLES[@members[u]] ? true : false
      can_edit = false if user == u
      can_edit = false if @members[user] == :user
      result[u] = [r, can_edit]
    end
    puts result
    result
  end
end

describe 'Permissions' do

  it 'tests can view' do
    u1 = User.new("Jozko1")
    u2 = User.new("Ferko2")
    u3 = User.new("Ancika2")
    a1 = Account.new("Firma 1", {u1 => :owner})
    a2 = Account.new("Firma 2", {u2 => :owner})

    #expect(u1).to respond_to(:can_view?).with(1).argument
    expect(u1.can_view?(a1)).to eq(true)
    expect(u1.can_view?(a2)).to eq(false)

    expect(u3.can_view?(a2)).to eq(false)
    a2 = a2.add_member(u3)
    expect(u3.can_view?(a2)).to eq(true)
    expect(u3.can_view?(a1)).to eq(false)
  end

  it 'tests roles in account' do
    u1 = User.new("Jozko1")
    u2 = User.new("Ferko2")
    u3 = User.new("Anicka")
    u4 = User.new("Palo")
    u5 = User.new("Adam")
    a1 = Account.new("Firma 1", {u1 => :owner})
    a1 = a1.add_member(u2)
    a1 = a1.add_member_with_role(u3, :admin)
    a1 = a1.add_member(u4)
    a1 = a1.add_member_with_role(u4, :admin)

    expect(a1.list_users(u1)).to eq({u1 => [:owner, false], u2 => [:user, true], u3 => [:admin, true], u4 => [:admin, true]})
    expect(a1.list_users(u2)).to eq({u1 => [:owner, false], u2 => [:user, false], u3 => [:admin, false], u4 => [:admin, false]})
    expect(a1.list_users(u3)).to eq({u1 => [:owner, false], u2 => [:user, true], u3 => [:admin, false], u4 => [:admin, true]})

    a1 = a1.add_member(u5)
    expect(a1.list_users(u2)).to eq({u1 => [:owner, false], u2 => [:user, false], u3 => [:admin, false], u4 => [:admin, false], u5 => [:user, false]})
  end
end