require 'date'

module ActsAsCalendar
  def self.included(base)
    base.send :extend, ClassMethods
  end
end

module ClassMethods
  def acts_as_calendar(options={})
    cattr_accessor :calendar_start_dt_field, :calendar_end_dt_field, :calendar_event_title_field
    
    self.calendar_start_dt_field = (options[:calendar_start_dt_field] || :start_dt).to_s
    self.calendar_end_dt_field = (options[:calendar_end_dt_field] || :end_dt).to_s
    self.calendar_event_title_field = (options[:calendar_event_title_field] || :event_title).to_s
    
    send :include, InstanceMethods
  end
  
  # generate the calendar for month
  def calendar(year, month, day=nil, optional_params = {})
    attr_accessor :events # a hash to put events into that will be parsed
    attr_accessor :cal # the calendar object, stores useful information about the date range
    
    # set the calendar mode if it was not set
    optional_params[:mode] = Calendar::MODE_CALENDAR if optional_params[:mode].nil?
    
    # if year month and day are nil then use today as the main point
    if year.nil? && month.nil? && day.nil?
      year = Time.now.strftime("%Y").to_i
      month = Time.now.strftime("%m").to_i
      day = Time.now.strftime("%d").to_i
    end
    day = 1 if day.nil?
    
    @cal = Calendar.new(year, month, day, optional_params[:mode])
    @events = {}
    
    # get the range for the month
    start_date = @cal.start_date
    end_date = @cal.end_date
    
    # initialize the event hash
    start_date.upto(end_date){|date|
      @events[date.to_s] = Array.new
    }
    
    conditions = Array.new
    values = Array.new
    conditions << self.calendar_start_dt_field + ' >= ?'
    values << start_date
    conditions << self.calendar_end_dt_field + ' <= ?'
    values << end_date
    
    conditions = conditions.join(' AND ')
    
    unless optional_params[:conditions].nil? || optional_params[:conditions].empty?
        conditions += optional_params[:conditions].shift.to_s
        optional_params[:conditions].each do |value|
          values << value     
        end
    end
    
    conditions = [conditions] + values
    
    # get all of the events for that range
    event_data = find(:all, 
                                    :conditions => conditions,
                                    :order => self.calendar_start_dt_field + ' ASC')
     
    # add each event into the correct date field in the @events hash
    event_data.each do |event_datum|
      date = Date.parse(event_datum.read_attribute(event_datum.class.calendar_start_dt_field).to_s)
      @events[date.to_s] << event_datum
    end
    
    # return the events and the calendar object (as Array)
    return @events, @cal
  end
end

module InstanceMethods
  # add any instance methods for the object
  # ex: @user.some_instance_method
  
  # TODO: methods to add:
  #
  # overlaps with existing event
  # conflicts with existing event
  # conflicts with existing event with conditions on it (like only reservations in one location)
  # 
  #
end
