require 'date'

module CalendarHelper
  
  ###################################################
  #
  # Builds a calendar 
  # @param cal Calendar Object
  # @param collection Hash to be used to fill in day information
  # @param partial String the partial to be used to fill in day information
  # @return calendar in html form
  #
  ###################################################
  def generate_calendar(calendar_data, partial=nil)
    @events = calendar_data[0] unless calendar_data.nil?
    @cal = calendar_data[1] unless calendar_data.nil?
    if !@cal.nil?
      header =  calendar_header(@cal)
      calendar_header = tag(:br) + calendar_day_headers
      cal_body =  calendar_body(@cal, @events, partial)
    else
      header = ''
      calendar_header = ''
      cal_body = ''
    end
    return content_tag(:div,(header+
                                        tag(:br) +
                                        render(:partial => 'calendar/form', :object => @cal) + 
                                        calendar_header +
                                        cal_body
                                      ), :id => 'calendar_container')
  end
  
  ###################################################
  #
  # builds the calendar header the Month day, YEAR
  # @return content_tag of the month header
  #
  ###################################################
  def calendar_header(cal)
    content_tag(:div, cal.month_name + ' ' + cal.day.to_s + ', ' + cal.year.to_s, :id => 'month_header')
  end
  
  ###################################################
  #
  # Builds the calendar day header for a month
  # @return content_tag of the day headers
  #
  ###################################################
  def calendar_day_headers
    headers = Array.new     
    Date::DAYNAMES.each do |day|
      headers << content_tag(:div, day, :id => 'day_header')
    end
    headers << content_tag(:div, nil, :id => 'clear_div')
    content_tag(:div, headers.join , :id => 'day_headers')
  end
  
  ###################################################
  # 
  #  builds the body of the calendar
  #  @param cal Calendar  Object
  #  @param collection Hash Object to be passed into the partial
  #  @param partial String the partial that is to be rendered
  #  
  ####################################################
  def calendar_body(cal, events=nil, partial=nil)
      weeks = Array.new
      week = Array.new
      # build the first week
      if cal.start_dow > 0
        offset = 0
        while offset < cal.start_dow
          week << content_tag(:div, '&nbsp;', :id => 'day_blank')
          offset += 1
        end
      end

      # build the rest of the calendar
      cal.start_date.upto(cal.end_date) { |date| 
        dow = date.strftime("%w").to_i
        
        # figure out the class name
        style = 'day'
        if cal.selected_date == date
          style += '_curr'
        end
        
        # build the day div w/ the data that should be put there
        content = date.strftime("%d").to_s + tag(:br)
        if !events[date.to_s].nil? && !partial.nil?
          @events = events[date.to_s]
          content += render(:partial => partial, :object => @events) 
        end
        week << content_tag(:div, content, :id => style)
        
        if dow != 0 && ((dow % 6) == 0) && date.strftime("%w").to_i < 28
          week << content_tag(:div, '', :id => 'clear_div')
          weeks << content_tag(:div, week.join, :id => 'week')
          week.clear
        end
      }
      
      # build the last days offset 
      if cal.end_dow < 6
        offset = cal.end_dow
        while offset < 6
          week << content_tag(:div, '&nbsp;', :id => 'day_blank')
          offset += 1
        end
      end
      
      # combine all of the weeks to finish the calendar build
      weeks << content_tag(:div, week.join, :id => 'week')
      week.clear

      weeks = weeks.join
      return weeks
    end
end
