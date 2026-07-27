# Implementation Plan - Enhanced New Delivery Destination Registration

Improve the "New Registration" (新規登録) flow in the Order Entry screen by providing three distinct search patterns, optimizing user experience and API usage.

## Proposed Changes

### 1. `AddressService` Enhancements
Add flexible search methods to `AddressService.dart` to handle the new search patterns:
- **`searchByLocationAndCategory`**: Filter by prefecture, city, and a predefined category/genre mapping (using keywords).
- **`searchByAddressOrZip`**: Search the `kigyou`, `medical`, and `post_all` tables using a partial address or exact zip code.
- **`searchByLocationAndKeyword`**: Search by prefecture, city, and a custom keyword in `company_name` or `address`.

### 2. Category/Genre Definition
Define a hierarchical mapping that matches common car navigation systems:
- **医療・福祉**: 病院, 歯科医院, クリニック, 介護施設
- **公共施設**: 役所・役場, 警察署, 消防署, 学校, 公園
- **商業・店舗**: スーパー, コンビニ, デパート, 飲食店
- **工場・工業**: 工場, 製作所, 工業, 倉庫
- **企業・オフィス**: 一般企業, 銀行, 保険, 放送局

### 3. `OrderFormScreen` UI Redesign
Update the `_buildNewAddressForm` widget to include a navigation/tab system for the three patterns:

#### Pattern 1: Area & Category
- Prefecture selection (Dropdown/List)
- City selection (Filtered by prefecture)
- Category & Genre selection (Chips or Tiles)

#### Pattern 2: Address or Zip Code
- Single input field for "Address or Zip Code"
- Automatic detection and search

#### Pattern 3: Area & Keyword
- Reuse Prefecture/City selection from Pattern 1
- Custom Keyword input field

### 4. Search Result Display
- Search results for all patterns will be displayed in the **right sidebar** under the map.
- Selecting a result will populate the form and update the map immediately.

## Verification Plan

### Manual Verification
1. **Category Search**: Select "愛知県" -> "岡崎市" -> "医療" -> "歯科". Verify that only dentists in Okazaki appear in the sidebar.
2. **Zip Search**: Enter "444-0011". Verify that facilities in that area appear.
3. **Keyword Search**: Select "岡崎市" and enter "トヨタ". Verify that Toyota-related facilities in Okazaki appear.
4. **Map Reflection**: Ensure every selection moves the map and places a marker correctly.
