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
                console.log(data);
                _this.won(data.product_id);
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
    this.updateBidPriceAndStatus(this.value, 'label-danger', 'label-success', 'Your Bid');
    this.addMessage("success", "Success!", "Your bid has been placed. The new price is: $" + parseFloat(this.value).toFixed(2));
};

AuctionSocket.prototype.underbid = function(value) {
    this.addMessage("danger", "Uh Oh!", "Your bid of $" + parseFloat(value).toFixed(2) + " is too low.");
};

AuctionSocket.prototype.outbid = function(value) {
    this.updateBidPriceAndStatus(value, 'label-success', 'label-danger', 'Not Your Bid');
    this.addMessage("warning", "FYI:", "You were outbid. The new top bid is: $" + parseFloat(value).toFixed(2));
};

AuctionSocket.prototype.won = function(productId) {
    this.updateBidStatus("label-danger", "label-success", "You Won");
    this.removeBidInput();
    this.changeTimeLeftToEnded();
    this.form.after('<a class="btn btn-sm btn-primary" rel="nofollow" data-method="put" href="/products/' + productId + '/transfer">Claim this product</a>');
    this.addMessage("success", "Hooray!", "You have won this auction.");
};

AuctionSocket.prototype.lost = function() {
    this.updateBidStatus("label-success", "label-danger", "You Lost");
    this.removeBidInput();
    this.changeTimeLeftToEnded();
    this.addMessage("danger", "Uh oh!", "This auction has ended, and someone else has won.");
};

AuctionSocket.prototype.addMessage = function(classString, headerString, messageString) {
    $("#socket-messages div.alert").remove();
    $("#socket-messages").prepend(
        '<div class="alert alert-' + classString + ' alert-dismissible fade in" role="alert"><button type="button" class="close" data-dismiss="alert" aria-label="Close"><span aria-hidden="true">&times;</span></button><strong>' + headerString + '</strong> ' + messageString + '</div>'
    );
};

AuctionSocket.prototype.updateBidPriceAndStatus = function(value, removeClass, addClass, html) {
    $('#current-bid-price').html("$" + parseFloat(value).toFixed(2));
    this.updateBidStatus(removeClass, addClass, html);
};

AuctionSocket.prototype.updateBidStatus = function(removeClass, addClass, html) {
    if (!$('#bid-status').length) {
        $('#current-bid-price').after('<span id="bid-status" class="label"></span>');
    }

    $('#bid-status').removeClass(removeClass).addClass(addClass).html(html);
};

AuctionSocket.prototype.removeBidInput = function() {
    this.form.slideUp();
};

AuctionSocket.prototype.changeTimeLeftToEnded = function() {
    $("#js-auction-time-left").html("This Auction Has Ended!");
};
