require 'calendar'
require 'acts_as_calendar'
require 'calendar_helper'

ActiveRecord::Base.send :include, ActsAsCalendar
ActionView::Base.send :include, CalendarHelper
