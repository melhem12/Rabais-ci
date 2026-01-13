# RABAIS CI - Complete API Documentation

**Base URL**: `http://72.61.163.98/api`

**Authentication**: All protected endpoints require Bearer token in Authorization header:
```
Authorization: Bearer <access_token>
```

---

## 📋 Table of Contents

### Customer Endpoints
1. [Authentication](#1-authentication)
2. [Wallet Management](#2-wallet-management)
3. [Voucher Operations](#3-voucher-operations)
4. [Purchase Operations](#4-purchase-operations)
5. [Purchase via Barcode](#5-purchase-via-barcode)

### Merchant Endpoints
6. [Merchant Authentication](#6-merchant-authentication)
7. [Redemption Operations](#7-redemption-operations)
8. [Merchant Dashboard](#8-merchant-dashboard)

### Common Endpoints
9. [Business Information](#9-business-information)
10. [File Uploads](#10-file-uploads)

---

## 1. Authentication

### 1.1 Request OTP
**Endpoint**: `POST /auth/phone/otp/request`

**Request Body**:
```json
{
  "phone": "+225012345678"
}
```

**Response** (200 OK):
```json
{
  "message": "OTP sent successfully",
  "expires_in": 300
}
```

### 1.2 Verify OTP
**Endpoint**: `POST /auth/phone/otp/verify`

**Request Body**:
```json
{
  "phone": "+225012345678",
  "otp": "1234"
}
```

**Response** (200 OK):
```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": "user_123",
    "name": "John Doe",
    "phone": "+225012345678",
    "role": "client",
    "first_time_login": true,
    "phone_verified": true,
    "email": null,
    "first_name": null,
    "last_name": null,
    "date_of_birth": null,
    "gender": null,
    "additional_info": null,
    "profile_image_url": null,
    "created_at": "2024-01-01T00:00:00Z",
    "updated_at": "2024-01-01T00:00:00Z"
  }
}
```

### 1.3 Get Current User
**Endpoint**: `GET /auth/me`  
**Authentication**: Required

**Response** (200 OK):
```json
{
  "id": "user_123",
  "name": "John Doe",
  "phone": "+225012345678",
  "role": "client",
  "first_time_login": false,
  "phone_verified": true,
  "email": "john.doe@example.com",
  "first_name": "John",
  "last_name": "Doe",
  "date_of_birth": "1990-01-01",
  "gender": "male",
  "additional_info": null,
  "profile_image_url": "https://example.com/profile.jpg",
  "created_at": "2024-01-01T00:00:00Z",
  "updated_at": "2024-01-15T00:00:00Z",
  "wallet": {
    "id": "wallet_123",
    "coins": 500.0,
    "balance_minor": 10000.0,
    "currency": "XOF",
    "last_updated": "2024-01-15T00:00:00Z"
  }
}
```

### 1.4 Update Profile
**Endpoint**: `PUT /auth/me`  
**Authentication**: Required

**Request Body**:
```json
{
  "email": "john.doe@example.com",
  "first_name": "John",
  "last_name": "Doe",
  "date_of_birth": "1990-01-01",
  "gender": "male",
  "additional_info": "Some additional info"
}
```

**Response** (200 OK):
```json
{
  "id": "user_123",
  "name": "John Doe",
  "phone": "+225012345678",
  "role": "client",
  "first_time_login": false,
  "phone_verified": true,
  "email": "john.doe@example.com",
  "first_name": "John",
  "last_name": "Doe",
  "date_of_birth": "1990-01-01",
  "gender": "male",
  "additional_info": "Some additional info",
  "profile_image_url": null,
  "created_at": "2024-01-01T00:00:00Z",
  "updated_at": "2024-01-15T00:00:00Z"
}
```

### 1.5 Refresh Token
**Endpoint**: `POST /auth/refresh`

**Request Body**:
```json
{
  "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

**Response** (200 OK):
```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

---

## 2. Wallet Management

### 2.1 Get Wallet
**Endpoint**: `GET /wallet`  
**Authentication**: Required

**Response** (200 OK):
```json
{
  "id": "wallet_123",
  "coins": 500.0,
  "balance_minor": 10000.0,
  "currency": "XOF",
  "last_updated": "2024-01-15T00:00:00Z"
}
```

### 2.2 Get Transactions
**Endpoint**: `GET /wallet/transactions`  
**Authentication**: Required

**Query Parameters**:
- `page` (integer, optional): Page number (default: 1)
- `limit` (integer, optional): Items per page (default: 20)

**Response** (200 OK):
```json
[
  {
    "id": "trans_123",
    "type": "topup",
    "amount": 10000.0,
    "currency": "XOF",
    "date": "2024-01-15T10:00:00Z",
    "status": "completed",
    "description": "Wallet top-up via package",
    "reference": "PKG_123"
  },
  {
    "id": "trans_124",
    "type": "purchase",
    "amount": -5000.0,
    "currency": "XOF",
    "date": "2024-01-14T15:30:00Z",
    "status": "completed",
    "description": "Voucher purchase",
    "reference": "PUR_456"
  },
  {
    "id": "trans_125",
    "type": "voucher_coin_payment",
    "amount": -100.0,
    "currency": "COINS",
    "date": "2024-01-13T09:20:00Z",
    "status": "completed",
    "description": "Voucher purchase with coins",
    "reference": "PUR_789"
  }
]
```

**Transaction Types**:
- `topup`: Money added to wallet
- `purchase`: Money spent on voucher
- `voucher_coin_payment`: Coins spent on voucher
- `refund`: Money/coins refunded
- `transfer`: Money transferred

**Transaction Status**:
- `pending`: Transaction pending
- `completed`: Transaction completed
- `failed`: Transaction failed
- `cancelled`: Transaction cancelled

### 2.3 Get Coin Packages
**Endpoint**: `GET /wallet/packages`  
**Authentication**: Required

**Response** (200 OK):
```json
[
  {
    "id": "pkg_123",
    "name": "Starter Pack",
    "price": 5000.0,
    "coins": 100.0,
    "currency": "XOF",
    "is_active": true,
    "description": "100 coins for 5000 XOF"
  },
  {
    "id": "pkg_124",
    "name": "Premium Pack",
    "price": 10000.0,
    "coins": 250.0,
    "currency": "XOF",
    "is_active": true,
    "description": "250 coins for 10000 XOF"
  },
  {
    "id": "pkg_125",
    "name": "Mega Pack",
    "price": 20000.0,
    "coins": 600.0,
    "currency": "XOF",
    "is_active": true,
    "description": "600 coins for 20000 XOF"
  }
]
```

### 2.4 Top Up Wallet
**Endpoint**: `POST /wallet/topup`  
**Authentication**: Required

**Request Body**:
```json
{
  "package_id": "pkg_123"
}
```

**Response** (200 OK):
```json
{
  "id": "trans_126",
  "type": "topup",
  "amount": 100.0,
  "currency": "COINS",
  "date": "2024-01-15T12:00:00Z",
  "status": "completed",
  "description": "Wallet top-up via Starter Pack",
  "reference": "PKG_123"
}
```

---

## 3. Voucher Operations

### 3.1 Get Vouchers
**Endpoint**: `GET /vouchers`  
**Authentication**: Optional (more details if authenticated)

**Query Parameters**:
- `page` (integer, optional): Page number (default: 1)
- `limit` (integer, optional): Items per page (default: 20)
- `category` (string, optional): Filter by category
- `search` (string, optional): Search in title/description

**Response** (200 OK):
```json
[
  {
    "id": "voucher_123",
    "business_id": "business_123",
    "title": "50% Off on Pizza",
    "description": "Get 50% discount on all pizzas at Pizza Palace",
    "price_minor": 5000.0,
    "coin_price": 50.0,
    "discount_value": 50.0,
    "type": "paid",
    "quantity": 100,
    "is_unlimited": false,
    "remaining_quantity": 75,
    "status": "active",
    "image_url": "/uploads/vouchers/pizza.jpg",
    "business": {
      "id": "business_123",
      "name": "Pizza Palace",
      "logo_url": "/uploads/business/logo.jpg",
      "category": "Restaurant",
      "contact_phone": "+225012345678",
      "contact_email": "contact@pizzapalace.ci"
    }
  },
  {
    "id": "voucher_124",
    "business_id": "business_124",
    "title": "Free Coffee",
    "description": "Get a free coffee with any purchase",
    "price_minor": 0.0,
    "coin_price": 25.0,
    "discount_value": 100.0,
    "type": "free",
    "quantity": 50,
    "is_unlimited": false,
    "remaining_quantity": 30,
    "status": "active",
    "image_url": null,
    "business": {
      "id": "business_124",
      "name": "Coffee Shop",
      "logo_url": "/uploads/business/coffee_logo.jpg",
      "category": "Café",
      "contact_phone": "+225098765432",
      "contact_email": "info@coffeeshop.ci"
    }
  }
]
```

**Voucher Types**:
- `free`: Free voucher (price_minor = 0)
- `paid`: Paid voucher

**Voucher Status**:
- `active`: Voucher is active and available
- `inactive`: Voucher is inactive
- `expired`: Voucher has expired
- `sold_out`: Voucher is sold out

### 3.2 Get Voucher Details
**Endpoint**: `GET /vouchers/{voucher_id}`  
**Authentication**: Optional

**Response** (200 OK):
```json
{
  "id": "voucher_123",
  "business_id": "business_123",
  "title": "50% Off on Pizza",
  "description": "Get 50% discount on all pizzas at Pizza Palace. Valid until end of month.",
  "price_minor": 5000.0,
  "coin_price": 50.0,
  "discount_value": 50.0,
  "type": "paid",
  "quantity": 100,
  "is_unlimited": false,
  "remaining_quantity": 75,
  "status": "active",
  "image_url": "/uploads/vouchers/pizza.jpg",
  "valid_from": "2024-01-01T00:00:00Z",
  "valid_until": "2024-01-31T23:59:59Z",
  "terms_and_conditions": "Cannot be combined with other offers. Valid only at Pizza Palace.",
  "business": {
    "id": "business_123",
    "name": "Pizza Palace",
    "logo_url": "/uploads/business/logo.jpg",
    "category": "Restaurant",
    "contact_phone": "+225012345678",
    "contact_email": "contact@pizzapalace.ci",
    "address": "123 Main Street, Abidjan",
    "website": "https://pizzapalace.ci"
  }
}
```

---

## 4. Purchase Operations

### 4.1 Purchase Voucher (Standard)
**Endpoint**: `POST /vouchers/{voucher_id}/buy`  
**Authentication**: Required

**Request Body**:
```json
{
  "payment_method": "wallet"
}
```

**Payment Methods**:
- `wallet`: Pay with wallet balance (XOF)
- `coins`: Pay with coins
- `mixed`: Pay with both wallet and coins (if insufficient in one)

**Response** (201 Created):
```json
{
  "id": "purchase_123",
  "voucher_id": "voucher_123",
  "voucher_title": "50% Off on Pizza",
  "amount": 5000.0,
  "currency": "XOF",
  "status": "completed",
  "purchase_date": "2024-01-15T12:00:00Z",
  "qr_code": "PUR_123_QR_DATA",
  "valid_until": "2024-01-31T23:59:59Z",
  "barcode": "1234567890123",
  "redeem_code": "REDEEM123",
  "payment_details": {
    "payment_method": "wallet",
    "amount_paid": 5000.0,
    "coins_used": 0.0,
    "wallet_balance_after": 5000.0,
    "coins_balance_after": 500.0
  },
  "voucher_details": {
    "id": "voucher_123",
    "title": "50% Off on Pizza",
    "discount_value": 50.0,
    "image_url": "/uploads/vouchers/pizza.jpg",
    "business": {
      "id": "business_123",
      "name": "Pizza Palace",
      "logo_url": "/uploads/business/logo.jpg"
    }
  }
}
```

**Purchase Status**:
- `pending`: Purchase is pending payment
- `completed`: Purchase completed successfully
- `failed`: Purchase failed
- `cancelled`: Purchase cancelled
- `refunded`: Purchase refunded

**Error Response** (400 Bad Request):
```json
{
  "detail": "Insufficient wallet balance. Required: 5000 XOF, Available: 3000 XOF"
}
```

**Error Response** (404 Not Found):
```json
{
  "detail": "Voucher not found"
}
```

**Error Response** (422 Unprocessable Entity):
```json
{
  "detail": "Voucher is out of stock"
}
```

### 4.2 Purchase Voucher with Coins
**Endpoint**: `POST /vouchers/{voucher_id}/buy`  
**Authentication**: Required

**Request Body**:
```json
{
  "payment_method": "coins"
}
```

**Response** (201 Created):
```json
{
  "id": "purchase_124",
  "voucher_id": "voucher_124",
  "voucher_title": "Free Coffee",
  "amount": 0.0,
  "coin_amount": 25.0,
  "currency": "COINS",
  "status": "completed",
  "purchase_date": "2024-01-15T12:30:00Z",
  "qr_code": "PUR_124_QR_DATA",
  "valid_until": "2024-01-31T23:59:59Z",
  "barcode": "1234567890124",
  "redeem_code": "REDEEM124",
  "payment_details": {
    "payment_method": "coins",
    "amount_paid": 0.0,
    "coins_used": 25.0,
    "wallet_balance_after": 10000.0,
    "coins_balance_after": 475.0
  },
  "voucher_details": {
    "id": "voucher_124",
    "title": "Free Coffee",
    "discount_value": 100.0,
    "image_url": null,
    "business": {
      "id": "business_124",
      "name": "Coffee Shop",
      "logo_url": "/uploads/business/coffee_logo.jpg"
    }
  }
}
```

### 4.3 Get User Purchases
**Endpoint**: `GET /purchases`  
**Authentication**: Required

**Query Parameters**:
- `page` (integer, optional): Page number (default: 1)
- `limit` (integer, optional): Items per page (default: 20)
- `status` (string, optional): Filter by status (pending, completed, failed, cancelled, refunded)

**Response** (200 OK):
```json
[
  {
    "id": "purchase_123",
    "voucher_id": "voucher_123",
    "voucher_title": "50% Off on Pizza",
    "amount": 5000.0,
    "currency": "XOF",
    "status": "completed",
    "purchase_date": "2024-01-15T12:00:00Z",
    "qr_code": "PUR_123_QR_DATA",
    "valid_until": "2024-01-31T23:59:59Z",
    "barcode": "1234567890123",
    "redeem_code": "REDEEM123",
    "is_redeemed": false,
    "redeemed_at": null,
    "voucher_details": {
      "id": "voucher_123",
      "business": {
        "id": "business_123",
        "name": "Pizza Palace",
        "logo_url": "/uploads/business/logo.jpg"
      }
    }
  },
  {
    "id": "purchase_124",
    "voucher_id": "voucher_124",
    "voucher_title": "Free Coffee",
    "amount": 0.0,
    "coin_amount": 25.0,
    "currency": "COINS",
    "status": "completed",
    "purchase_date": "2024-01-14T10:00:00Z",
    "qr_code": "PUR_124_QR_DATA",
    "valid_until": "2024-01-31T23:59:59Z",
    "barcode": "1234567890124",
    "redeem_code": "REDEEM124",
    "is_redeemed": true,
    "redeemed_at": "2024-01-14T15:30:00Z",
    "voucher_details": {
      "id": "voucher_124",
      "business": {
        "id": "business_124",
        "name": "Coffee Shop",
        "logo_url": "/uploads/business/coffee_logo.jpg"
      }
    }
  }
]
```

### 4.4 Get Purchase Details
**Endpoint**: `GET /purchases/{purchase_id}`  
**Authentication**: Required

**Response** (200 OK):
```json
{
  "id": "purchase_123",
  "voucher_id": "voucher_123",
  "voucher_title": "50% Off on Pizza",
  "amount": 5000.0,
  "currency": "XOF",
  "status": "completed",
  "purchase_date": "2024-01-15T12:00:00Z",
  "qr_code": "PUR_123_QR_DATA",
  "valid_until": "2024-01-31T23:59:59Z",
  "barcode": "1234567890123",
  "redeem_code": "REDEEM123",
  "is_redeemed": false,
  "redeemed_at": null,
  "payment_details": {
    "payment_method": "wallet",
    "amount_paid": 5000.0,
    "coins_used": 0.0,
    "transaction_id": "trans_124"
  },
  "voucher_details": {
    "id": "voucher_123",
    "title": "50% Off on Pizza",
    "description": "Get 50% discount on all pizzas",
    "discount_value": 50.0,
    "image_url": "/uploads/vouchers/pizza.jpg",
    "business": {
      "id": "business_123",
      "name": "Pizza Palace",
      "logo_url": "/uploads/business/logo.jpg",
      "category": "Restaurant",
      "contact_phone": "+225012345678",
      "contact_email": "contact@pizzapalace.ci",
      "address": "123 Main Street, Abidjan"
    }
  }
}
```

### 4.5 Get Purchase QR Code
**Endpoint**: `GET /purchases/{purchase_id}/qr`  
**Authentication**: Required

**Response** (200 OK):
```json
{
  "qr_payload": "PUR_123_QR_DATA",
  "barcode": "1234567890123",
  "redeem_code": "REDEEM123"
}
```

---

## 5. Purchase via Barcode

### 5.1 Scan Barcode and Purchase
**Endpoint**: `POST /vouchers/buy-by-barcode`  
**Authentication**: Required

**Request Body**:
```json
{
  "barcode": "1234567890123",
  "payment_method": "wallet"
}
```

**Response** (201 Created):
```json
{
  "id": "purchase_125",
  "voucher_id": "voucher_123",
  "voucher_title": "50% Off on Pizza",
  "amount": 5000.0,
  "currency": "XOF",
  "status": "completed",
  "purchase_date": "2024-01-15T13:00:00Z",
  "qr_code": "PUR_125_QR_DATA",
  "valid_until": "2024-01-31T23:59:59Z",
  "barcode": "1234567890123",
  "redeem_code": "REDEEM125",
  "payment_details": {
    "payment_method": "wallet",
    "amount_paid": 5000.0,
    "coins_used": 0.0,
    "wallet_balance_after": 5000.0,
    "coins_balance_after": 500.0
  },
  "voucher_details": {
    "id": "voucher_123",
    "title": "50% Off on Pizza",
    "discount_value": 50.0,
    "image_url": "/uploads/vouchers/pizza.jpg",
    "business": {
      "id": "business_123",
      "name": "Pizza Palace",
      "logo_url": "/uploads/business/logo.jpg"
    }
  }
}
```

**Error Response** (404 Not Found):
```json
{
  "detail": "Voucher with barcode '1234567890123' not found"
}
```

**Error Response** (422 Unprocessable Entity):
```json
{
  "detail": "Voucher is not available for purchase (inactive or out of stock)"
}
```

### 5.2 Get Voucher by Barcode (Preview)
**Endpoint**: `GET /vouchers/by-barcode/{barcode}`  
**Authentication**: Optional

**Response** (200 OK):
```json
{
  "id": "voucher_123",
  "business_id": "business_123",
  "title": "50% Off on Pizza",
  "description": "Get 50% discount on all pizzas at Pizza Palace",
  "price_minor": 5000.0,
  "coin_price": 50.0,
  "discount_value": 50.0,
  "type": "paid",
  "quantity": 100,
  "is_unlimited": false,
  "remaining_quantity": 75,
  "status": "active",
  "image_url": "/uploads/vouchers/pizza.jpg",
  "barcode": "1234567890123",
  "business": {
    "id": "business_123",
    "name": "Pizza Palace",
    "logo_url": "/uploads/business/logo.jpg",
    "category": "Restaurant",
    "contact_phone": "+225012345678",
    "contact_email": "contact@pizzapalace.ci"
  }
}
```

---

## 6. Merchant Authentication

### 6.1 Merchant Login (Same as Customer)
**Endpoint**: `POST /auth/phone/otp/verify`

**Request Body**:
```json
{
  "phone": "+225098765432",
  "otp": "1234",
  "role": "merchant"
}
```

**Response** (200 OK):
```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": "merchant_123",
    "name": "Pizza Palace Owner",
    "phone": "+225098765432",
    "role": "merchant",
    "first_time_login": false,
    "phone_verified": true,
    "email": "owner@pizzapalace.ci",
    "business_id": "business_123",
    "created_at": "2024-01-01T00:00:00Z",
    "updated_at": "2024-01-15T00:00:00Z"
  }
}
```

---

## 7. Redemption Operations

### 7.1 Redeem Voucher (QR Code or Manual Code)
**Endpoint**: `POST /redeem`  
**Authentication**: Required (Merchant)

**Request Body**:
```json
{
  "code": "REDEEM123"
}
```

**OR** (for QR code):
```json
{
  "qr_code": "PUR_123_QR_DATA"
}
```

**Response** (200 OK):
```json
{
  "ok": true,
  "message": "Voucher redeemed successfully",
  "purchase_id": "purchase_123",
  "redemption": {
    "id": "redemption_123",
    "purchase_id": "purchase_123",
    "voucher_title": "50% Off on Pizza",
    "amount": 5000.0,
    "currency": "XOF",
    "redemption_date": "2024-01-15T14:00:00Z",
    "status": "completed",
    "customer_phone": "+225012345678",
    "method": "qr_code",
    "location": "Pizza Palace - Abidjan"
  }
}
```

**Error Response** (404 Not Found):
```json
{
  "ok": false,
  "message": "Purchase not found or invalid code"
}
```

**Error Response** (422 Unprocessable Entity):
```json
{
  "ok": false,
  "message": "Voucher already redeemed"
}
```

**Error Response** (422 Unprocessable Entity):
```json
{
  "ok": false,
  "message": "Voucher has expired"
}
```

### 7.2 Get Redemption History
**Endpoint**: `GET /admin/redemptions`  
**Authentication**: Required (Merchant)

**Query Parameters**:
- `page` (integer, optional): Page number (default: 1)
- `limit` (integer, optional): Items per page (default: 20)
- `start_date` (string, optional): Filter from date (ISO 8601)
- `end_date` (string, optional): Filter to date (ISO 8601)

**Response** (200 OK):
```json
[
  {
    "id": "redemption_123",
    "purchase_id": "purchase_123",
    "voucher_title": "50% Off on Pizza",
    "amount": 5000.0,
    "currency": "XOF",
    "redemption_date": "2024-01-15T14:00:00Z",
    "status": "completed",
    "customer_phone": "+225012345678",
    "method": "qr_code",
    "location": "Pizza Palace - Abidjan"
  },
  {
    "id": "redemption_124",
    "purchase_id": "purchase_124",
    "voucher_title": "Free Coffee",
    "amount": 0.0,
    "currency": "COINS",
    "redemption_date": "2024-01-14T16:00:00Z",
    "status": "completed",
    "customer_phone": "+225012345679",
    "method": "manual_code",
    "location": "Coffee Shop - Cocody"
  }
]
```

### 7.3 Get Redemption Statistics
**Endpoint**: `GET /admin/redemptions/stats`  
**Authentication**: Required (Merchant)

**Query Parameters**:
- `start_date` (string, optional): Filter from date (ISO 8601)
- `end_date` (string, optional): Filter to date (ISO 8601)

**Response** (200 OK):
```json
{
  "total_redemptions": 150,
  "total_amount": 750000.0,
  "currency": "XOF",
  "today_redemptions": 5,
  "today_amount": 25000.0,
  "this_week_redemptions": 25,
  "this_week_amount": 125000.0,
  "this_month_redemptions": 75,
  "this_month_amount": 375000.0,
  "by_method": {
    "qr_code": 100,
    "manual_code": 50
  },
  "top_vouchers": [
    {
      "voucher_id": "voucher_123",
      "voucher_title": "50% Off on Pizza",
      "redemption_count": 75,
      "total_amount": 375000.0
    },
    {
      "voucher_id": "voucher_124",
      "voucher_title": "Free Coffee",
      "redemption_count": 50,
      "total_amount": 0.0
    }
  ]
}
```

---

## 8. Merchant Dashboard

### 8.1 Get Merchant Business Info
**Endpoint**: `GET /business`  
**Authentication**: Required (Merchant)

**Response** (200 OK):
```json
{
  "id": "business_123",
  "name": "Pizza Palace",
  "logo_url": "/uploads/business/logo.jpg",
  "category": "Restaurant",
  "contact_phone": "+225012345678",
  "contact_email": "contact@pizzapalace.ci",
  "address": "123 Main Street, Abidjan",
  "website": "https://pizzapalace.ci",
  "description": "Best pizza in Abidjan",
  "created_at": "2024-01-01T00:00:00Z",
  "updated_at": "2024-01-15T00:00:00Z"
}
```

### 8.2 Get Merchant Vouchers
**Endpoint**: `GET /business/vouchers`  
**Authentication**: Required (Merchant)

**Query Parameters**:
- `page` (integer, optional): Page number (default: 1)
- `limit` (integer, optional): Items per page (default: 20)
- `status` (string, optional): Filter by status

**Response** (200 OK):
```json
[
  {
    "id": "voucher_123",
    "title": "50% Off on Pizza",
    "description": "Get 50% discount on all pizzas",
    "price_minor": 5000.0,
    "coin_price": 50.0,
    "discount_value": 50.0,
    "type": "paid",
    "quantity": 100,
    "is_unlimited": false,
    "remaining_quantity": 75,
    "status": "active",
    "image_url": "/uploads/vouchers/pizza.jpg",
    "created_at": "2024-01-01T00:00:00Z",
    "total_purchases": 25,
    "total_revenue": 125000.0
  }
]
```

### 8.3 Create Voucher (Merchant)
**Endpoint**: `POST /business/vouchers`  
**Authentication**: Required (Merchant)

**Request Body**:
```json
{
  "title": "Buy 2 Get 1 Free",
  "description": "Buy 2 pizzas and get 1 free",
  "price_minor": 10000.0,
  "coin_price": 100.0,
  "discount_value": 33.33,
  "type": "paid",
  "quantity": 50,
  "is_unlimited": false,
  "valid_from": "2024-01-20T00:00:00Z",
  "valid_until": "2024-02-20T23:59:59Z",
  "terms_and_conditions": "Valid only on weekdays"
}
```

**Response** (201 Created):
```json
{
  "id": "voucher_126",
  "business_id": "business_123",
  "title": "Buy 2 Get 1 Free",
  "description": "Buy 2 pizzas and get 1 free",
  "price_minor": 10000.0,
  "coin_price": 100.0,
  "discount_value": 33.33,
  "type": "paid",
  "quantity": 50,
  "is_unlimited": false,
  "remaining_quantity": 50,
  "status": "active",
  "image_url": null,
  "valid_from": "2024-01-20T00:00:00Z",
  "valid_until": "2024-02-20T23:59:59Z",
  "barcode": "1234567890126",
  "created_at": "2024-01-15T15:00:00Z"
}
```

### 8.4 Update Voucher (Merchant)
**Endpoint**: `PUT /business/vouchers/{voucher_id}`  
**Authentication**: Required (Merchant)

**Request Body**:
```json
{
  "title": "Buy 2 Get 1 Free - Updated",
  "description": "Buy 2 pizzas and get 1 free (Updated)",
  "quantity": 75,
  "status": "active"
}
```

**Response** (200 OK):
```json
{
  "id": "voucher_126",
  "title": "Buy 2 Get 1 Free - Updated",
  "description": "Buy 2 pizzas and get 1 free (Updated)",
  "quantity": 75,
  "remaining_quantity": 50,
  "status": "active",
  "updated_at": "2024-01-15T16:00:00Z"
}
```

---

## 9. Business Information

### 9.1 Get Business Partners
**Endpoint**: `GET /business/partners`  
**Authentication**: Optional

**Query Parameters**:
- `category` (string, optional): Filter by category
- `search` (string, optional): Search in name

**Response** (200 OK):
```json
[
  {
    "id": "business_123",
    "name": "Pizza Palace",
    "logo_url": "/uploads/business/logo.jpg",
    "category": "Restaurant",
    "contact_phone": "+225012345678",
    "contact_email": "contact@pizzapalace.ci",
    "address": "123 Main Street, Abidjan",
    "website": "https://pizzapalace.ci",
    "active_vouchers_count": 5
  },
  {
    "id": "business_124",
    "name": "Coffee Shop",
    "logo_url": "/uploads/business/coffee_logo.jpg",
    "category": "Café",
    "contact_phone": "+225098765432",
    "contact_email": "info@coffeeshop.ci",
    "address": "456 Coffee Street, Cocody",
    "website": "https://coffeeshop.ci",
    "active_vouchers_count": 3
  }
]
```

### 9.2 Get Sponsored Banners
**Endpoint**: `GET /admin/sponsored`  
**Authentication**: Optional

**Response** (200 OK):
```json
[
  {
    "id": "banner_123",
    "business_id": "business_123",
    "business_name": "Pizza Palace",
    "business_logo_url": "/uploads/business/logo.jpg",
    "image_url": "/uploads/sponsored/pizza_banner.jpg",
    "priority": 1,
    "link_url": "/vouchers/voucher_123"
  },
  {
    "id": "banner_124",
    "business_id": "business_124",
    "business_name": "Coffee Shop",
    "business_logo_url": "/uploads/business/coffee_logo.jpg",
    "image_url": "/uploads/sponsored/coffee_banner.jpg",
    "priority": 2,
    "link_url": "/vouchers/voucher_124"
  }
]
```

---

## 10. File Uploads

### 10.1 Upload Business Logo
**Endpoint**: `POST /uploads/business/logo`  
**Authentication**: Required (Merchant)  
**Content-Type**: `multipart/form-data`

**Request Body**:
```
file: [binary file data]
```

**Response** (200 OK):
```json
{
  "url": "/uploads/business/logo_123.jpg",
  "message": "Logo uploaded successfully"
}
```

### 10.2 Upload Voucher Image
**Endpoint**: `POST /uploads/voucher/image`  
**Authentication**: Required (Merchant)  
**Content-Type**: `multipart/form-data`

**Request Body**:
```
file: [binary file data]
```

**Response** (200 OK):
```json
{
  "url": "/uploads/vouchers/voucher_123.jpg",
  "message": "Image uploaded successfully"
}
```

---

## Error Responses

All error responses follow this format:

### 400 Bad Request
```json
{
  "detail": "Invalid request parameters"
}
```

### 401 Unauthorized
```json
{
  "detail": "Authentication required"
}
```

### 403 Forbidden
```json
{
  "detail": "You don't have permission to perform this action"
}
```

### 404 Not Found
```json
{
  "detail": "Resource not found"
}
```

### 422 Unprocessable Entity
```json
{
  "detail": "Validation error: [specific error message]"
}
```

### 500 Internal Server Error
```json
{
  "detail": "Internal server error"
}
```

---

## Notes for Backend Implementation

### Barcode Format
- Barcodes should be unique per voucher
- Format: 13-digit EAN-13 barcode (recommended)
- Barcode should be generated when voucher is created
- Store barcode in database with voucher

### QR Code Format
- QR codes for purchases should contain: `PUR_{purchase_id}_{timestamp}`
- QR codes should be unique per purchase
- Generate QR code payload after purchase completion
- Store QR payload in purchase record

### Payment Processing
- Validate wallet balance before processing purchase
- Validate coin balance if payment method is coins
- Create transaction record for each payment
- Update wallet/coin balance atomically

### Redemption Process
- Validate redeem code/QR code exists
- Check if already redeemed
- Check if expired
- Create redemption record
- Update purchase status to "redeemed"
- Return redemption confirmation

### Pagination
- All list endpoints support pagination
- Default page size: 20
- Maximum page size: 100
- Return total count if possible:
  ```json
  {
    "data": [...],
    "pagination": {
      "page": 1,
      "limit": 20,
      "total": 100,
      "total_pages": 5
    }
  }
  ```








