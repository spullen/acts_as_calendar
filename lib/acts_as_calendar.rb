require 'date'

module ActsAsCalendar
  def self.included(base)
    base.send :extend, ClassMethods
  end
end

module ClassMethods
  ########################################
  #
  # acts_as_calendar gives your model the calendar functionality
  # @params options Hash, optional
  #
  ########################################
  def acts_as_calendar(options={})
    cattr_accessor :calendar_start_dt_field, 
                   :calendar_end_dt_field, 
                   :calendar_event_title_field,
                   :calendar_start_time_field
    
    self.calendar_start_dt_field = (options[:calendar_start_dt_field] || :start_dt).to_s
    self.calendar_end_dt_field = (options[:calendar_end_dt_field] || :end_dt).to_s
    self.calendar_event_title_field = (options[:calendar_event_title_field] || :event_title).to_s
    self.calendar_start_time_field = (options[:calendar_start_time_field] || :start_time).to_s
    
    send :include, InstanceMethods
  end
  
  ########################################
  #
  # generate a calendar
  # call this function like YourModel.calendar(...)
  # @params year Integer
  # @params month Integer
  # @params day Integer, optional
  # @params optional_params Hash, optional
  # @returns events, cal Array(Hash, Calendar)
  # 
  ########################################
  def calendar(year, month, day=nil, optional_params = {})
    attr_accessor :events # a hash to put events into that will be parsed
    attr_accessor :cal # the calendar object, stores useful information about the date range
    
    # set the calendar mode if it was not set
    optional_params[:mode] = Calendar::MODE_MONTH if optional_params[:mode].nil?
    
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
                                    :order => self.calendar_start_time_field + ' ASC')
     
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
  
  ####################################
  #
  # Checks to see if an event being created overlaps with any
  # other event already created
  # @params extra_conditions Array, optional this is a conditional array [string, val_1, ... , val_n]
  # @returns Boolean false if there are no overlaps, otherwise true
  #
  ####################################
  def overlaps_with_existing?(extra_conditions = nil)
    # get the start and end date of the object
    start_date = Date.parse(self.read_attribute(self.class.calendar_start_dt_field).to_s)
    end_date = Date.parse(self.read_attribute(self.class.clendar_end_dt_field).to_s)
    
    conditions = Array.new
    vals = Array.new
    
    # add the default conditions and vals
    conditions << self.class.calendar_start_dt_field + ' >= ?'
    vals << start_date
    conditions << self.class.calendar_end_dt_field + ' <= ?'
    vals << end_date
    
    conditions = conditions.join(' AND ')
    
    # check to see if there are any extra_conditions and add them
    unless extra_conditions.nil?
      conditions += extra_conditions.shift.to_s
      extra_conditions.each do |val|
        vals << val
      end
    end
    
    conditions = [conditions] + vals
    
    # get all of the calendar events in that range
    events = find(:all, 
                              :conditions => conditions,
                              :order => self.class.calendar_start_dt_field)
   
    # iterate over the events found and check if there are any overlaps
    overlaps = false
    current_start_dt = self.read_attribute(self.class.calendar_start_dt_field) 
    current_end_dt = self.read_attribute(self.class.calendar_end_dt_field)
    
    events.each do |event|
      tmp_start_dt = event.read_attribute(event.class.calendar_start_dt_field)
      tmp_end_dt = event.read_attribute(event.class.calendar_end_dt_field)
      
      if current_start_dt.between?(tmp_start_dt, tmp_end_dt) || current_end_dt.between?(tmp_start_dt, tmp_end_dt)
        overlaps = true
      end
        
      # if there is an overlap then stop the looping
      break if overlaps
    end
    
    return overlaps
  end
  
  #######################################
  #
  # Checks to see if there are any overlapping events
  # Similar to overlaps_with_existing? except this will return a 
  # recordset of the events that overlap with the current one
  # @params Array, optional: pass in a conditional array to constrain your search more
  # @returns Array || nil if there aren't any
  #
  #######################################
  def overlaps_with_existing(extra_conditions=nil)
    # get the start and end date of the object
    start_date = Date.parse(self.read_attribute(self.class.calendar_start_dt_field).to_s)
    end_date = Date.parse(self.read_attribute(self.class.clendar_end_dt_field).to_s)
    
    conditions = Array.new
    vals = Array.new
    
    # add the default conditions and vals
    conditions << self.class.calendar_start_dt_field + ' >= ?'
    vals << start_date
    conditions << self.class.calendar_end_dt_field + ' <= ?'
    vals << end_date
    
    conditions = conditions.join(' AND ')
    
    # check to see if there are any extra_conditions and add them
    unless extra_conditions.nil?
      conditions += extra_conditions.shift.to_s
      extra_conditions.each do |val|
        vals << val
      end
    end
    
    conditions = [conditions] + vals
    
    # get all of the calendar events in that range
    events = find(:all, 
                             :conditions => conditions,
                             :order => self.class.calendar_start_dt_field)
   
    # iterate over the events found and check if there are any overlaps
    overlaps = Array.new
    current_start_dt = self.read_attribute(self.class.calendar_start_dt_field) 
    current_end_dt = self.read_attribute(self.class.calendar_end_dt_field)
    
    events.each do |event|
      tmp_start_dt = event.read_attribute(event.class.calendar_start_dt_field)
      tmp_end_dt = event.read_attribute(event.class.calendar_end_dt_field)
      
      if current_start_dt.between?(tmp_start_dt, tmp_end_dt) || current_end_dt.between?(tmp_start_dt, tmp_end_dt)
        overlaps << event
      end
    end
    
    overlaps = nil unless overlaps.size > 0
    
    return overlaps
  end
end
