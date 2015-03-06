var AuctionSocket = function(user_id, auction_id, form) {
    this.user_id = user_id;
    this.auction_id = auction_id;
    this.form = $(form);

    this.socket = new WebSocket(App.websocket_url + "/auctions/" + this.auction_id);

    this.initBinds();
};

AuctionSocket.prototype.initBinds = function() {
    // Save this to a variable for use inside callback functions
    var _this = this;

    // Register a callback function for when the form is submitted
    this.form.submit(function(e) {
        e.preventDefault();
        _this.sendBid($("#bid_value").val());
    });

    // Register a callback function for when the socket returns a message
    this.socket.onmessage = function(e) {
        var data = $.parseJSON(e.data);
        var type = data.type;

        switch(type) {
            case "bidok":
                _this.bid(data.value);
                break;
            case "underbid":
                _this.underbid(data.value);
                break;
            case "outbid":
                _this.outbid(data.value);
                break;
            case "won":
                _this.won();
                break;
            case "lost":
                _this.lost();
                break;
            default:
                _this.addMessage("danger", "Uh oh!", data.message);
        }
    };
};

AuctionSocket.prototype.sendBid = function(value) {
    this.value = value;
    var template = "bid {{auction_id}} {{user_id}} {{value}}";
    this.socket.send(Mustache.render(template, {
        user_id: this.user_id,
        auction_id: this.auction_id,
        value: value
    }));
};

AuctionSocket.prototype.bid = function() {
    $('#current-bid-price').html("$" + parseFloat(this.value).toFixed(2));
    this.addMessage("success", "Success!", "Your bid has been placed. The new price is: $" + parseFloat(this.value).toFixed(2));
};

AuctionSocket.prototype.underbid = function(value) {
    if (value === null) {
        this.addMessage("danger", "Uh Oh!", "You must enter a bid.");
    }
    else {
        this.addMessage("danger", "Uh Oh!", "Your bid of $" + value + " is too low.");
    }
};

AuctionSocket.prototype.outbid = function(value) {
    this.addMessage("warning", "FYI:", "You were outbid. The new top bid is: " + value);
};

AuctionSocket.prototype.won = function() {
    this.addMessage("success", "Hooray!", "You won the auction!");
};

AuctionSocket.prototype.lost = function() {
    this.addMessage("danger", "Uh oh!", "You lost the auction!");
};

AuctionSocket.prototype.addMessage = function(classString, headerString, messageString) {
    this.form.find("#socket-messages div.alert").remove();
    this.form.find("#socket-messages").prepend(
        '<div class="alert alert-' + classString + ' alert-dismissible fade in" role="alert"><button type="button" class="close" data-dismiss="alert" aria-label="Close"><span aria-hidden="true">&times;</span></button><strong>' + headerString + '</strong> ' + messageString + '</div>'
    );
};
