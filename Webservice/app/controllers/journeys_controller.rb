class JourneysController < ApplicationController
  include ActionController::MimeResponds
  require 'net/http'
  require "easyaccess/base"
  require "easyaccess/journeys"

  def index
    respond_to do |format|
      if (!params.has_key?(:from) || !params.has_key?(:to) || !params.has_key?(:datetime))
        @data = jsonResponseFormat(1, "error", {:error => "Please provide the longitude, latidute and datetime"})
      else
        # get parameters
        @info = Hash.new()
        @info[:from] = params[:from].to_s.gsub(",", ";")
        @info[:to] = params[:to].to_s.gsub(",", ";")
        @info[:datetime] = params[:datetime]

        # Optional
        @info[:mode] = params[:mode]

        # To avoid certain lines, modes...
        @info[:forbidden_uris] = ["RapidTransit","Metro","CheckOut","CheckIn","default_physical_mode"]

        # The different journey types
        @info[:type] = ["comfort","best","rapid","less_fallback_walk", "fastest"]

        # Get the itinerary from CANALTP
        @api = EasyAccess::Base.new(:info => @info)
        @result, @error = @api.journeys.itinerary()

        # Check if an error is returned
        if (!@error)
          @data = jsonResponseFormat(1, "error", {:error => @result})
        else
          @data = jsonResponseFormat(0, "success", @result)
        end
      end
      format.json { render :json => @data }
    end
  end

  private
  # json return format
  def jsonResponseFormat(responseCode, responseMessage, result)
    return { :responseCode => responseCode,
             :responseMessage => responseMessage,
             :result => result }
  end


end
