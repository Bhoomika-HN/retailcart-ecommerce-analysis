# RetailCart — E-Commerce Sales & Profitability Analysis

**SQL-based analysis of 1,000 orders across 7 product categories, 5 marketing channels, and 5 geographic regions to identify revenue drivers, margin inefficiencies, and actionable business opportunities.**

---

## Business Problem

RetailCart's leadership flagged a concern: revenue is growing but overall profitability feels under pressure. The goal of this analysis was to diagnose *where* the margin is being lost — whether it's a category problem, a channel problem, a regional problem, or a combination — and to provide evidence-backed recommendations rather than directional guesses.

---

## Dataset

| Attribute | Detail |
|---|---|
| Source | Simulated RetailCart order-level data |
| Rows | 1,000 orders |
| Period | November 2024 – April 2025 (6 months) |
| Database | PostgreSQL |

**Columns:** `order_id`, `order_date`, `category`, `channel`, `region`, `revenue`, `cogs`, `discount`, `delivery_cost`, `profit`

**Important limitation:** The dataset has no `customer_id`. All channel and category metrics are order-level, not customer-level. Metrics such as repeat purchase rate, customer lifetime value, and unique customers per channel cannot be derived from this data.

---

## Tools Used

- PostgreSQL — data extraction, aggregation, window functions, CTEs
- SQL techniques: `RANK() OVER()`, `PARTITION BY`, `SUM() OVER()`, `DATE_TRUNC()`, `FILTER (WHERE ...)`, `CASE WHEN`

---

## Analysis Structure

| Section | Focus |
|---|---|
| A | Data Profiling |
| B | Revenue & Profit Drivers |
| C | Margin & Efficiency Analysis |
| D | Discount Impact Analysis |
| E | Concentration Risk |
| F | Loss & Risk Analysis |
| G | Category Deep Dive — Electronics |
| H | Category Deep Dive — Books |
| I | Channel Deep Dive — Paid Ads |
| J | Regional Deep Dive |
| K | Time Trend Analysis |

---

## Key Findings

### 1. Revenue is dominated by Electronics — but it is the least efficient category

Electronics contributes **50.2% of total revenue** and **41.9% of total profit**, yet operates at the **lowest profit margin of any category (26.55%)** — 9.15 percentage points below the average of all other categories (35.70%). Order counts across all seven categories are nearly identical (133–154 orders each), confirming that Electronics' revenue dominance comes entirely from its **Average Order Value of ₹12,271** — 20x higher than Books (₹617) and 3–4x higher than most other categories.

### 2. Electronics' margin gap is a COGS problem, not a discount or logistics problem

A root-cause breakdown across discount %, COGS %, and delivery cost % reveals that Electronics' **COGS is 72.1% of revenue** — 12+ percentage points above the next-highest category (Toys at 59.9%). Its discount rate (16.3%) and delivery cost % (1.35% — the lowest of any category) are actually favorable. The margin gap is entirely a **supplier cost issue**, not a customer-facing pricing issue. Reducing Electronics' sticker price or discounting would not address the root cause. Supplier renegotiation is the correct lever.

### 3. Fashion is the most efficient category and is being underutilised

Fashion has the **highest profit margin of any category (43.10%)** while maintaining a mid-range discount rate (15.43%). Despite this, Fashion contributes only **7.84% of total revenue** — less than a sixth of Electronics' share. The business is generating its most efficient profit from one of its smallest revenue contributors. Increasing Fashion's marketing investment and product assortment has a higher margin-per-rupee-spent return than pushing more Electronics volume.

### 4. Paid Ads is the least efficient channel by a significant margin

Paid Ads generates 19.3% of total revenue but only 14.4% of total profit — the **largest gap between revenue share and profit share of any channel (-4.9 percentage points)**. Its discount rate of **29.28%** is nearly 5x Referral's 6.58% and 2x Organic Search's 8.72%. Referral and Organic Search show the opposite pattern — both convert revenue into profit at a *higher* rate than their revenue share would suggest, driven by single-digit discount rates.

### 5. Books sold via Paid Ads loses money on 39% of orders

Books has the lowest AOV (₹617) of any category. Delivery cost per order across all categories is virtually identical at ~₹160–165 — it is a flat, fixed operational cost regardless of what is shipped. For Books, this fixed cost represents **26.7% of order value**. When Paid Ads' 29.28% discount is applied on top, insufficient revenue remains to cover COGS plus delivery. The result: **39.3% of Books orders through Paid Ads are loss-making** — more than double the next-highest channel (Referral at 16.7%). This is the most concentrated, actionable loss in the dataset.

### 6. Central is the highest-revenue region but the lowest-margin region

Central generates the most revenue (23.8% share) but has the **lowest profit margin of any region (30.48%)**. West has the least revenue (17.4% share) but the **highest margin (33.54%)**. Delivery cost does not explain this — Central's delivery cost is mid-range, not the highest (East is highest at ₹39,779 vs Central's ₹34,728). Central's discount rate of **17.65%** — the highest of any region — is the more likely driver of its margin underperformance.

### 7. December's revenue drop is explained by a category mix shift, not a demand collapse

December showed the lowest AOV of any month (₹3,080 vs the typical ₹3,600–3,800) and a revenue dip to ₹4,89,788 against the normal ~₹6,00,000–6,30,000 range — yet it also showed the **highest profit margin of any month (33.16%)**. The explanation is a category mix shift: Electronics' share of December orders fell from its typical 14.5% to 11.3%, while Toys (18.2%) and Books (17.0%) rose above their normal proportions. Fewer high-AOV, low-margin Electronics orders simultaneously reduced blended AOV and improved blended margin. Whether this is a recurring seasonal pattern cannot be confirmed from 6 months of data.

---

## Business Recommendations

**1. Investigate Electronics supplier costs**
The 9.15-point margin gap between Electronics and all other categories traces entirely to COGS (72.1% of revenue). Renegotiating supplier terms or qualifying alternative suppliers is the highest-leverage margin improvement available. Note: this dataset cannot quantify how much COGS is reducible — that requires supplier-level data not available here.

**2. Exclude or cap discounts for Books on Paid Ads**
Books via Paid Ads loses money on 39.3% of orders. Since Books is a minor revenue contributor (2.49% of total), stopping or significantly reducing Books-specific Paid Ads discounts is a low-risk, direct fix for the dataset's most concentrated loss. The structural cause (low AOV + high discount + fixed delivery cost) is fully evidenced; the fix does not require any behavioral assumptions about customers.

**3. Reallocate marketing budget from Paid Ads toward Referral and Organic Search**
Referral (profit share 26.7% vs revenue share 23.0%) and Organic Search (23.4% vs 20.5%) already outperform their revenue share without heavy discounting. Paid Ads (14.4% profit vs 19.3% revenue) underperforms despite the highest discount spend of any channel. Shifting budget toward channels that already prove higher efficiency — without testing discount sensitivity — is the lower-risk of the two channel interventions.

**4. Increase investment in Fashion**
Fashion is the highest-margin category (43.10%) with only 7.84% revenue share. Increasing Fashion's marketing presence and product range would improve the business's overall blended margin without requiring any change to Electronics' pricing or operations.

**5. Test a minimum order value for Books delivery subsidy**
Since delivery cost is a flat ~₹165 per order regardless of category, very low-value Book orders structurally cannot absorb the full cost combination of COGS + discount + delivery. Introducing a free-delivery threshold (e.g., free delivery for orders above ₹500, delivery charged for lower-value orders) would protect per-order economics without changing Books' product price. Adoption rate is unknown and would need to be piloted before broad rollout.

**6. Investigate Central region's discount rate**
Central has the highest discount rate of any region (17.65%) and the lowest margin (30.48%). Before drawing a definitive conclusion, it is worth checking whether Central's product mix (e.g., more Electronics sold there) or its channel mix (more Paid Ads orders originating from Central) is causing the discount rate to appear high at the region level — or whether Central-specific promotional activity is genuinely over-discounting.

---

## What This Analysis Cannot Answer

- **Customer-level behavior** — no `customer_id` means repeat purchases, churn, and lifetime value are unmeasurable
- **Causality of seasonal patterns** — 6 months of data is insufficient to confirm recurring seasonality; year-over-year comparison is needed
- **Price elasticity** — this dataset cannot predict how order volume would respond to discount cuts or price changes; any recommendation involving pricing should be tested via A/B pilot before broad rollout
- **Why Electronics COGS is high** — the data confirms COGS is the margin driver but cannot distinguish between "inherently expensive hardware" and "fixable sourcing inefficiency"

---

## Repository Structure

```
retailcart-ecommerce-analysis/
├── data/
│   └── retailcart_orders.csv
├── retailcart_analysis.sql
└── README.md
```

---

*Analysis performed in PostgreSQL. Dataset is simulated order-level data designed for portfolio purposes.*
