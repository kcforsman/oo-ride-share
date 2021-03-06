require_relative 'spec_helper'
require 'time'
# require 'pry'

describe "TripDispatcher class" do
  describe "Initializer" do
    it "is an instance of TripDispatcher" do
      dispatcher = RideShare::TripDispatcher.new
      dispatcher.must_be_kind_of RideShare::TripDispatcher
    end

    it "establishes the base data structures when instantiated" do
      dispatcher = RideShare::TripDispatcher.new
      [:trips, :passengers, :drivers].each do |prop|
        dispatcher.must_respond_to prop
      end

      dispatcher.trips.must_be_kind_of Array
      dispatcher.passengers.must_be_kind_of Array
      dispatcher.drivers.must_be_kind_of Array
    end
  end

  describe "find_driver method" do
    before do
      @dispatcher = RideShare::TripDispatcher.new
    end

    it "throws an argument error for a bad ID" do
      proc{ @dispatcher.find_driver(0) }.must_raise ArgumentError
    end

    it "finds a driver instance" do
      driver = @dispatcher.find_driver(2)
      driver.must_be_kind_of RideShare::Driver
    end
  end

  describe "find_passenger method" do
    before do
      @dispatcher = RideShare::TripDispatcher.new
    end

    it "throws an argument error for a bad ID" do
      proc{ @dispatcher.find_passenger(0) }.must_raise ArgumentError
    end

    it "finds a passenger instance" do
      passenger = @dispatcher.find_passenger(2)
      passenger.must_be_kind_of RideShare::Passenger
    end
  end

  describe "loader methods" do
    it "accurately loads driver information into drivers array" do
      dispatcher = RideShare::TripDispatcher.new

      first_driver = dispatcher.drivers.first
      last_driver = dispatcher.drivers.last

      first_driver.name.must_equal "Bernardo Prosacco"
      first_driver.id.must_equal 1
      first_driver.status.must_equal :UNAVAILABLE
      last_driver.name.must_equal "Minnie Dach"
      last_driver.id.must_equal 100
      last_driver.status.must_equal :AVAILABLE
    end

    it "accurately loads passenger information into passengers array" do
      dispatcher = RideShare::TripDispatcher.new

      first_passenger = dispatcher.passengers.first
      last_passenger = dispatcher.passengers.last

      first_passenger.name.must_equal "Nina Hintz Sr."
      first_passenger.id.must_equal 1
      last_passenger.name.must_equal "Miss Isom Gleason"
      last_passenger.id.must_equal 300
    end

    it "accurately loads trip info and associates trips with drivers and passengers" do
      dispatcher = RideShare::TripDispatcher.new

      trip = dispatcher.trips.first
      driver = trip.driver
      passenger = trip.passenger

      driver.must_be_instance_of RideShare::Driver
      driver.trips.must_include trip
      passenger.must_be_instance_of RideShare::Passenger
      passenger.trips.must_include trip
    end

    it "stores end_time and start_time as instances of Time" do
      dispatcher = RideShare::TripDispatcher.new

      trip = dispatcher.trips.first
      start_time = trip.start_time
      end_time = trip.end_time

      start_time.must_be_instance_of Time
      end_time.must_be_instance_of Time
    end
  end

  describe "request_trip" do
    before do
      @trip_dispatcher = RideShare::TripDispatcher.new
      @new_trip = @trip_dispatcher.request_trip(33)
    end
    it "throws an error for an invalid passenger id" do
      proc { @trip_dispatcher.request_trip(nil) }.must_raise ArgumentError
      proc { @trip_dispatcher.request_trip("not an id") }.must_raise ArgumentError
    end

    it "returns a newly created trip" do
      @new_trip.must_be_instance_of RideShare::Trip
    end

    it "assigns value of 'nil' to end_time, cost, and rating" do
      @new_trip.end_time.must_be_nil
      @new_trip.cost.must_be_nil
      @new_trip.rating.must_be_nil
    end

    it "has start_time of now" do
      another_trip = @trip_dispatcher.request_trip(18)

      another_trip.start_time.ctime.must_equal Time.now.ctime
    end

    it "has an existing driver that is now :UNAVAILABLE" do
      driver = @new_trip.driver
      same_driver = @trip_dispatcher.find_driver(driver.id)
      driver.must_equal same_driver
      driver.status.must_equal :UNAVAILABLE
      driver.must_be_instance_of RideShare::Driver
    end

    it "adds new trip to both passenger's, driver's, and trip dispatcher trips" do
      driver = @new_trip.driver
      passenger = @new_trip.passenger

      driver.trips.must_include @new_trip
      passenger.trips.must_include @new_trip
      @trip_dispatcher.trips.must_include @new_trip
    end

    it 'returns nil if no drivers are available' do
      available_drivers = @trip_dispatcher.drivers.map { | driver | driver.status == :AVAILABLE }
      available_drivers.length.times do |x|
        @trip_dispatcher.request_trip(x + 1)
      end
      @trip_dispatcher.request_trip(300).must_be_nil
    end
  end

  describe 'find_least_recently_active_driver' do
    before do
      @trip_dispatcher = RideShare::TripDispatcher.new
      @driver = @trip_dispatcher.find_least_recently_active_driver
    end

    it 'returns a driver who is available' do
      @driver.must_be_instance_of RideShare::Driver
      @driver.status.must_equal :AVAILABLE
    end

    it 'returns the driver with the least recent trip' do
      # driver = @trip_dispatcher.find_least_recently_active_driver
      @trip_dispatcher.request_trip(2)
      driver_2 = @trip_dispatcher.find_least_recently_active_driver
      @trip_dispatcher.request_trip(4)
      driver_3 = @trip_dispatcher.find_least_recently_active_driver
      @trip_dispatcher.request_trip(5)
      driver_4 = @trip_dispatcher.find_least_recently_active_driver
      @trip_dispatcher.request_trip(67)
      driver_5 = @trip_dispatcher.find_least_recently_active_driver

      @driver.name.must_equal "Minnie Dach"
      driver_2.name.must_equal "Antwan Prosacco"
      driver_3.name.must_equal "Nicholas Larkin"
      driver_4.name.must_equal "Mr. Hyman Wolf"
      driver_5.name.must_equal "Jannie Lubowitz"
    end

  end
end
