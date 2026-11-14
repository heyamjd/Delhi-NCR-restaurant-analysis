# Delhi NCR Restaurant Market Analysis

**Business question:** If someone opens a new restaurant in Delhi NCR, which
locality and cuisine give the best chance of success, and which features matter?

**Live dashboard:** https://public.tableau.com/app/profile/amajad.manihar/viz/DelhiNCRRestaurantMarketExplorer/DelhiNCRRestaurantMarketExplorer?publish=yes
[Dashboard](dashboard/image.png)
## Key findings
1. **Chains rate lower than independents:** 3.17 vs 3.31 average rating.
   The gap persists within price ranges 2 and 3, but not in the cheapest
   segment (range 1).
2. **Table booking looks valuable but is confounded by price:** restaurants
   with booking average 3.51 vs 3.23 without. But booking share rises from
   0% (price range 1) to 82% (range 4). Within each price range the advantage
   disappears (range 2: +0.06, p = 0.10; range 4: -0.16).
3. **Top-rated localities:** Gurgaon Sector 29 (3.89), Cyber Hub (3.86),
   Hauz Khas Village (3.85), among 103 localities with 20+ rated restaurants.
4. **Votes track ratings** (Spearman rho = 0.59); cost correlates weakly (0.27).
5. **Ratings differ by city** (ANOVA p < 0.001); Noida and Faridabad rate lower.


## Method
Python (pandas, SciPy) for cleaning and tests, SQLite for 8 queries (CTEs,
window functions), Tableau Public for the dashboard.

## Data cleaning decisions
- Kept Delhi NCR only (92% of India rows; other cities had under 30 rows each)
- 27% of restaurants are unrated: flagged, excluded from rating analysis
- 396 restaurants had placeholder coordinates (0,0): set to missing
- 1 test listing removed
- Chain = restaurant name appears 5+ times

## Limitations
- Single snapshot, no time dimension, so no trend analysis
- Zomato user ratings only, 92% of data is Delhi NCR
- Association, not causation
- 113 rated restaurants lack valid coordinates and are not on the map
- Dashboard cuisine uses each restaurant's first listed cuisine only
- Minimum-count filters (20 per area, 30 per cuisine) can empty the bar
  charts for small filter combinations

## How to run
Run notebooks 01 to 06 in order, then queries in sql/queries.sql.