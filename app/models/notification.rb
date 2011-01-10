#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.
#
class Notification < ActiveRecord::Base
  require File.join(Rails.root, 'lib/diaspora/web_socket')
  include Diaspora::Socketable

  belongs_to :recipient, :class_name => 'User'
  has_many :notification_actors
  has_many :actors, :class_name => 'Person', :through => :notification_actors, :source => :person
  belongs_to :target, :polymorphic => true

  def self.for(recipient, opts={})
    self.where(opts.merge!(:recipient_id => recipient.id)).order('created_at desc')
  end

  def self.notify(recipient, target, actor)
    if target.respond_to? :notification_type
      if action = target.notification_type(recipient, actor)
        n = create(:target => target,
               :action => action,
               :actor => actor,
               :recipient => recipient)
        n.socket_to_uid(recipient.id) if n
        n
       end
    end
  end
end
