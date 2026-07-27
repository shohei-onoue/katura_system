# Walkthrough - Enhanced New Delivery Destination Search

I have completely redesigned the "New Registration" (新規登録) flow in the Order Form to provide a powerful, multi-pattern search experience similar to a professional car navigation system.

## Key Enhancements

### 1. Hierarchical Search (Area & Category)
- **UI**: Added a "Region & Category" tab.
- **Logic**: Users can select a **Prefecture** and **City**, then browse through predefined **Categories** (e.g., Medical, Public Facilities, Commerce) and **Genres** (e.g., Hospital, Dentist, Convenience Store).
- **Benefit**: Extremely useful when the exact name isn't known, but the area and type are.

### 2. Direct Search (Address or Zip Code)
- **UI**: Added a dedicated "Address & Zip" tab.
- **Logic**: Automatically detects if the input is a Zip Code (7 digits) or a partial Address and searches the internal database accordingly.
- **Benefit**: Fast entry for known addresses.

### 3. Local Keyword Search (Area & Keyword)
- **UI**: Added a "Region & Keyword" tab.
- **Logic**: Searches for specific terms (like "Toyota" or "Okazaki Hotel") within a selected City.
- **Benefit**: Targeted searching within a specific geographic scope.

### 4. Result Integration & API Savings
- **Unified Sidebar**: All search results are funneled into the right sidebar under the map.
- **One-Tap Selection**: Tapping a result immediately populates the "Confirmed Facility" and "Confirmed Address" fields and updates the map.
- **Smart Caching**: Coordinates found in the database are used directly. If a facility has no coordinates, they are fetched via Google Maps API and then **saved to the database** for future use.

## How to Test

1. Go to **受注入力 (Order Entry)** -> Proceed to **配達先の確定 (Step 3)**.
2. Select **新規登録 (New Registration)**.
3. Try the three tabs:
    - **地域・カテゴリ**: Select "愛知県" -> "岡崎市" -> "医療・福祉" -> "歯科医院" and click search.
    - **住所・郵便番号**: Enter "444-0011" and click search.
    - **地域・キーワード**: Select "岡崎市" and enter "ホテル" then click search.
4. Verify results appear in the right sidebar and selecting one updates the map.

> [!NOTE]
> 施設名や住所を確定させた後、必要に応じて「お渡し場所」や「受取人名」を追記して保存してください。
