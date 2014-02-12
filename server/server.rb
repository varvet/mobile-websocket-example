require "em-websocket"

EventMachine.run do
  @channel = EM::Channel.new
  
  EventMachine::WebSocket.start(host: "0.0.0.0", port: 8080, debug: true) do |ws|
    ws.onopen do
      sid = @channel.subscribe { |msg| ws.send(msg) }
      @channel.push("#{sid} connected")

      ws.onmessage { |msg| @channel.push("<#{sid}> #{msg}") }
      
      ws.onclose { @channel.unsubscribe(sid) }
    end
  end
end
