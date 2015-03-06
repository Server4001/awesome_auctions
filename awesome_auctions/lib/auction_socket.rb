require 'json'
require File.expand_path "../place_bid", __FILE__

class AuctionSocket
  def initialize app
    @app = app

    # Create array that will hold the list of ALL the socket connections
    # This works, because the middleware class is instantiated only once, when the server boots up
    @clients = []
  end

  def call env
    # Create an environment variable for env
    @env = env

    # Check to see if this is a websocket request
    if Faye::WebSocket.websocket? env
      # Create a new socket connection and add callbacks
      socket = spawn_socket

      # Add the new socket connection to the list
      @clients << socket

      # Return async Rack response, so that the stack can continue
      socket.rack_response
    else
      # Normal HTTP request
      @app.call env
    end
  end

  private

  # Getter for environment variable env
  attr_reader :env

  def spawn_socket
    # Create a new websocket connection
    socket = Faye::WebSocket.new env

    # Create a callback for when the socket sends a message
    socket.on :message do |event|
      begin
        # Get the operation type
        tokens = event.data.split " "
        operation = tokens.delete_at 0

        # Call methods based on operation type
        case operation
          when "bid"
            bid socket, tokens
        end
      rescue Exception => e
        p e
        e.backtrace
      end
    end

    socket
  end

  def bid socket, tokens
    # Get records from DB
    user = User.find tokens[1]
    auction = Auction.find tokens[0]

    begin
      # New up a PlaceBid
      service = PlaceBid.new({
        value: tokens[2],
        user: user,
        auction: auction
      })

      # Place the bid
      bid = service.execute

      # Build a response based on the bid results
      if bid === true
        response = {type: "bidok", value: tokens[2]}

        # Notify other socket connections that the bid has increased
        notify_outbids socket, tokens[2]
      else
        response = {type: "error", message: "An error occurred and your bid could not be placed"}
      end
    rescue BidTooSmall => e
      response = {type: "underbid", value: tokens[2]}
    rescue AuctionEnded => e
      if service.status === :won
        response = {type: "won", product_id: e.message}
      else
        response = {type: "lost", value: tokens[2]}
      end
    rescue NonNumeric => e
      response = {type: "error", message: e.message}
    rescue Exception => e
      response = {type: "error", message: e.message}
    end

    # Sends a response via the socket connection
    socket.send response.to_json
  end

  def notify_outbids socket, value
    @clients.reject { |client| client == socket }.each do |client|
      client.send({type: "outbid", value: value}.to_json)
    end
  end
end
