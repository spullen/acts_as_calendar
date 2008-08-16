require 'date'

class Calendar
  
  # constants for displaying calendars
  MODE_MONTH = 'month'
  MODE_WEEK = 'week'
  MODE_DAY = 'day'
  
  attr_accessor :year, :month, :day, :selected_date, :start_date, :start_dow, :end_date, :end_dow,
                              :prev_day, :prev_week, :prev_month, :prev_year, :next_day, :next_week, :next_month, :next_year,
                              :month_name, :mode
  
  def initialize(year, month, day, mode=MODE_MONTH)
    
    # if year month and day are nil then use today as the main point
    if year.nil? && month.nil? && day.nil?
      year = Time.now.strftime("%Y").to_i
      month = Time.now.strftime("%m").to_i
      day = Time.now.strftime("%d").to_i
    end
    day = 1 if day.nil?
    
    # fail 'year required' if year.nil?
    # fail 'month required' if month.nil?
    # fail 'day required' if day.nil? unless mode == MODE_MONTH
    
    # set the year month and day
    @year = year.to_i
    @month = month.to_i
    @day = day.to_i 
    
    @mode = mode
    
    # fail 'month not in range' if @month < 1 || @month > 12
    
    @selected_date = Date.new(@year, @month, @day)
    
    # depending on the mode set up the start and end dates
    if @mode == MODE_MONTH
      configure_month_mode
    elsif @mode == MODE_WEEK
      configure_week_mode
    elsif @mode == MODE_DAY
      configure_day_mode
    end
    
    # find the next and previous sets based on the selected date
    find_next_date_set
    find_prev_date_set
    
    # find the month name
    @month_name = Date::MONTHNAMES[@month]
  end
  
  #####################################
  #
  # Configure calendar object for month mode
  #
  #####################################
  def configure_month_mode
    # find the start date of the month
    @start_date = Date.new(@year, @month, 1)
    
    # find the end date of the month
    if (@month % 12) == 0
      @end_date = Date.new(@year+1, 1, 1)
    else
      @end_date = Date.new(@year, @month+1, 1)
    end
    @end_date = @end_date - 1
    
    # find the start and end dow
    @start_dow = @start_date.strftime("%w").to_i
    @end_dow = @end_date.strftime("%w").to_i
  end
  
  #####################################
  #
  # Configure calendar object for week mode
  #
  #####################################
  def configure_week_mode
    dow = @selected_date.strftime("%w").to_i
    
    if dow == 0
      @start_date = @selected_date
    else
      @start_date = (@selected_date - @selected_date.strftime("%w").to_i)
    end
    
    @end_date = @start_date + 6
    
    @start_dow = @start_date.strftime("%w").to_i
    @end_dow = @end_date.strftime("%w").to_i 
  end
  
  #####################################
  #
  # Configure calendar object for day mode
  #
  #####################################
  def configure_day_mode
    @start_date = @selected_date
    @end_date = @selected_date
    @start_dow = @start_date.strftime("%w").to_i
    @end_dow = @start_dow
  end
  
  #####################################
  #
  # Finds the next day, week, month, and year from a given
  # date
  #
  #####################################
  def find_next_date_set
    @next_day = @selected_date + 1
    @next_week = @selected_date + 7
    
    if (@month % 12) == 0
      new_day = @day
      while !Date.valid_civil?(@year + 1, 12, new_day)
        new_day = new_day - 1
      end
      @next_month = Date.new(@year+1, 1, new_day)
    else
      new_day = @day
      while !Date.valid_civil?(@year, @month+1, new_day)
        new_day = new_day - 1
      end
      @next_month = Date.new(@year, @month+1, new_day)
    end
    
    new_day = @day
    while !Date.valid_civil?(@year + 1, @month, new_day)
      new_day = new_day - 1
    end
    @next_year = Date.new(@year+1, @month, new_day) 
  end
  
  #####################################
  #
  # Finds the previous day, week, month and year from
  # a given date
  #
  #####################################
  def find_prev_date_set
    # find the prev and next everything
    @prev_day = @selected_date - 1
    @prev_week = @selected_date - 7
    
    if @month == 1
      new_day = @day
      while !Date.valid_civil?(@year - 1, 12, new_day)
        new_day = new_day - 1
      end
      @prev_month = Date.new(@year-1, 12, new_day)
    else
      new_day = @day
      while !Date.valid_civil?(@year, @month-1, new_day)
        new_day = new_day - 1
      end
      @prev_month = Date.new(@year, @month-1, new_day)
    end
    
    new_day = @day
    while !Date.valid_civil?(@year-1, @month, new_day)
      new_day = new_day - 1
    end
    @prev_year = Date.new(@year-1, @month, new_day)
  end
  
end
