$(function() {
    $(document).keyup(function(e) {
        if (e.key === "Escape") {
            $.post('https://genix_market/close', JSON.stringify({}));
        }
    });

    window.addEventListener('message', function(event) {
        var item = event.data;
        if (item.type === "ui") {
            if (item.status) {
                $(".container").fadeIn();
            } else {
                $(".container").fadeOut();
            }
        } else if (item.type === "updateItems") {
            items = item.items;
            updateItemList();
        }
    });

    $("#closeButton").click(function() {
        $.post('https://genix_market/close', JSON.stringify({}));
    });


   
});

function updateItemList() {
    const container = $("#itemContainer");
    container.empty();

    items.forEach(item => {
        const itemElement = `
            <div class="item-card">
                <img src="nui://ox_inventory/web/images/${item.name}.png" onerror="this.src='nui://ox_inventory/web/images/water.png'" alt="${item.label}">
                <div class="item-name">${item.label}</div>
                <div class="item-stock">Stock: ${item.stock}</div>
                <div class="item-price">$${item.price.toFixed(2)}</div>
                <button class="buy-button" onclick="addToCart('${item.name}')">Add to Cart</button>
            </div>
        `;
        container.append(itemElement);
    });
}

function addToCart(itemName) {
    const item = items.find(i => i.name === itemName);
    if (item && item.stock > 0) {
        const cartItem = cart.find(i => i.name === itemName);
        if (cartItem) {
            cartItem.quantity++;
        } else {
            cart.push({ ...item, quantity: 1 });
        }
        item.stock--;
        updateItemList();
        updateCart();
    }
}

function updateCart() {
    const cartContainer = $("#cartContainer");
    cartContainer.empty();
    let total = 0;

    cart.forEach(item => {
        const cartItemElement = `
            <div class="cart-item">
                <img src="nui://ox_inventory/web/images/${item.name}.png" onerror="this.src='nui://ox_inventory/web/images/water.png'" alt="${item.label}">
                <div class="cart-item-details">
                    <div class="cart-item-name">${item.label}</div>
                    <div class="cart-item-price">$${(item.price * item.quantity).toFixed(2)}</div>
                    <div class="cart-item-quantity">
                        <button class="quantity-btn" onclick="decreaseQuantity('${item.name}')">-</button>
                        <span>${item.quantity}</span>
                        <button class="quantity-btn" onclick="increaseQuantity('${item.name}')">+</button>
                    </div>
                </div>
                <button class="remove-item" onclick="removeFromCart('${item.name}')">X</button>
            </div>
        `;
        cartContainer.append(cartItemElement);
        total += item.price * item.quantity;
    });

    $("#totalAmount").text(`$${total.toFixed(2)}`);
}

function increaseQuantity(itemName) {
    const cartItem = cart.find(i => i.name === itemName);
    const item = items.find(i => i.name === itemName);
    if (cartItem && item.stock > 0) {
        cartItem.quantity++;
        item.stock--;
        updateItemList();
        updateCart();
    }
}

function decreaseQuantity(itemName) {
    const cartItem = cart.find(i => i.name === itemName);
    const item = items.find(i => i.name === itemName);
    if (cartItem && cartItem.quantity > 1) {
        cartItem.quantity--;
        item.stock++;
        updateItemList();
        updateCart();
    } else if (cartItem && cartItem.quantity === 1) {
        removeFromCart(itemName);
    }
}

function removeFromCart(itemName) {
    const cartItemIndex = cart.findIndex(i => i.name === itemName);
    if (cartItemIndex !== -1) {
        const item = items.find(i => i.name === itemName);
        item.stock += cart[cartItemIndex].quantity;
        cart.splice(cartItemIndex, 1);
        updateItemList();
        updateCart();
    }
}

function buyItems(paymentMethod) {
    if (cart.length === 0) return;

    $.post('https://genix_market/buyItems', JSON.stringify({
        items: cart,
        paymentMethod: paymentMethod
    }));

    cart = [];
    updateCart();
    $.post('https://genix_market/close', JSON.stringify({}));
}

let items = [];
let cart = [];
