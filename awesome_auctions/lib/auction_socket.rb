class AuctionSocket
  def initialize app
    # Create an environment variable for app
    @app = app
  end

  def call env
    # Check to see if this is a websocket request
    if Faye::WebSocket.websocket? env
      # Create a new websocket connection
      socket = Faye::WebSocket.new env

      # Create a callback for when the socket is created
      socket.on :open do
        socket.send "Hello!"
      end

      # Return async Rack response, so that the stack can continue
      socket.rack_response
    else
      # Normal HTTP request
      @app.call env
    end
  end
end
