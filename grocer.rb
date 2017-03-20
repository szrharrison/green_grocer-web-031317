require 'pry'

def list_items_a( cart )
  cart.map do |item|
    item.map { |k, v| k }
  end.flatten.uniq
end

def select_items_a( cart, item )
  cart.select do |cart_item|
    cart_item.key?(item)
  end
end

def select_items( cart, item )
  cart.select do |cart_item, item_info|
    cart_item == item
  end
end

def coupon_items( coupons )
  coupons.each_with_object({}) do |coupon, hash| hash[coupon[:item]] = coupon[:num]
  end
end

def valid_coupon?( cart, coupons )
  cart_items = cart.keys
  coupon_items = coupon_items( coupons )

  coupon_items.all? do |coupon_item, num|
    cart_items.include?( coupon_item ) && cart[coupon_item][:count] >= num
  end
end

def this_coupon( coupon_item, coupons )
  coupons.find do |coupon|
    coupon[:item] == coupon_item
  end
end

def total_cart ( cart )
  cart.values.reduce(0) do |total, item_info|
    total + item_info[:price] * item_info[:count]
  end
end
######################################################

def consolidate_cart( cart )
  # code here
  items = list_items_a( cart )

  items.each_with_object({}) do |item, hash|
    items_in_cart = select_items_a( cart, item )
    price = items_in_cart[0][item][:price]
    clearance = items_in_cart[0][item][:clearance]
    count = items_in_cart.length
    hash[item] = { price: price,
      clearance: clearance,
      count: count
    }
  end
end

def apply_coupons( cart, coupons )
  # code here
  coupon_items = coupon_items( coupons )
  cart_items = cart.keys

  if valid_coupon?( cart, coupons )
    coupon_items.each do |coupon_item, num|
      this_coupon = this_coupon( coupon_item, coupons )
      cart["#{coupon_item} W/COUPON"] = { price: this_coupon[:cost],
        clearance: cart[coupon_item][:clearance],
        count: 0
      }
      until ( cart[coupon_item][:count] - num ) < 0
        cart["#{coupon_item} W/COUPON"][:count] += 1
        cart[coupon_item][:count] -= num
      end
    end
  end
  # couponed_cart = cart.reject do |item, item_info|
  #   item_info[:count] == 0
  # end
  cart
end

def apply_clearance( cart )
  # code here
  cart.each do |item, item_info|
    if item_info[:clearance]
      item_info[:price] = (item_info[:price] * 0.8).round(1)
    end
  end
end

def checkout( cart, coupons )
  # code here
  consolidated_cart = consolidate_cart( cart )
  couponed_cart = apply_coupons( consolidated_cart, coupons )
  clearanced_cart = apply_clearance( couponed_cart )
  pre_discount = total_cart( clearanced_cart)

  if pre_discount > 100
    pre_discount * 0.9
  else
    pre_discount
  end
end
