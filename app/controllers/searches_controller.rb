class SearchesController < ApplicationController
  def index
    @searches = Search.all
  end

  def create

    # Stor form input of origin and destination in variables
    origin = params[:origin];
    destination = params[:destination];

    # Rudimentary form validation
    if origin == '' || destination == ''

      #redirect back to root if origin or destination are invalid and include a flash error message
      redirect_to '/', error: "An invalid origin or destination was entered, please try again."

    else

      require "net/http"
      require "uri"

      # Grab the Google API Key from the Encrypted Credentials File
      distance_api = Rails.application.credentials[:GOOGLE_DISTANCE_API_KEY]

      # URL for Google Distance Matrix API
      url = URI("https://maps.googleapis.com/maps/api/distancematrix/json?origins=#{origin}&destinations=#{destination}&units=imperial&key=#{distance_api}")

      # Fetch the data from the Google Matrix API
      https = Net::HTTP.new(url.host, url.port)
      https.use_ssl = true
      request = Net::HTTP::Get.new(url)
      response = https.request(request)

      # Parse the JSON response into something we can use
      body = JSON.parse(response.read_body)

      # Extract just the Distance and Duration from the returned JSON
      distance = body['rows'][0]['elements'][0]['distance']['text']
      duration = body['rows'][0]['elements'][0]['duration']['text']

      # Add the Distance and Duration into the Params variable to be passed to the Model for DB storage
      params['distance'] = distance;
      params['duration'] = duration;

      # Store the returned data in the database.
      @search = Search.new(search_params)

      # Save, and if it works, return back to the site root along with a flash message reporting the information
      if @search.save
        redirect_back_or_to '/', info: "The Distance between #{origin} <br> and #{destination} is #{distance}. <br> The travel time is calculated as #{duration}"
      else
        render :new, status: :unprocessable_entity
      end

    end
  end

  private
    def search_params
      params.permit(:origin, :destination, :distance, :duration)
    end
  end
