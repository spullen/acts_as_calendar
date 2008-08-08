require 'date'

class Calendar
  
  attr_accessor :year, :month, :day, :selected_date, :start_date, :start_dow, :end_date, :end_dow,
                          :prev_day, :prev_week, :prev_month, :prev_year, :next_day, :next_week, :next_month, :next_year,
                          :month_name
  
  def initialize(year, month, day)
    # convert the values to make sure they are integers
    year = year.to_i
    month = month.to_i
    day = day.to_i
    
    fail 'month not in range' if month < 1 || month > 12
    
    @year = year
    @month = month
    @day = day
    
    @selected_date = Date.new(@year, @month, @day)
    
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
    
    # find the month name
    @month_name = Date::MONTHNAMES[@month]
  end
end
