calculateProfit<- function(premium, term = 20, death_benefit = 50000, 
                           constant_interest = 0.03, discount_loading = 0.05,
                           initial_commision_percent = 0.8, annual_commission_percent = 0.05) {
  
interest_rates <- rep(constant_interest, term)
discount_addition <- discount_loading
discount_rates <- interest_rates + discount_addition
commission_percentages <- c(initial_commision_percent, rep(annual_commission_percent, term - 1))
expenses <- c(100, rep(12.5, term - 1))
lapse_rates <- rep(0.01, term)
mortality_rates <- seq(0.001222, 0.002522, length.out = term)
premium_loading <- 0.3 # charge on premium to make profit.

#premium <- 200 # change to see profit.

annual_discount_factor <- 1/(1 + discount_rates)
discount_factor <- rep(NA, term) # used to discount to present value.
discount_factor[1] <- annual_discount_factor[1]
for (i in 2:term) {
  discount_factor[i] <- annual_discount_factor[i] * discount_factor[i-1]
}
discount_factors_advance <- c(1, discount_factor[1:term-1])

inforce_eop <- rep(NA, term)
inforce_eop[1] <- 1 * ( 1 - mortality_rates[1] - lapse_rates[1])
for (i in 2:term) {
  inforce_eop[i] <-  inforce_eop[i-1] * (1 - mortality_rates[i] - lapse_rates[i])
}

inforce_sop <- c(1, inforce_eop[1: term-1])

deaths <- inforce_sop * mortality_rates
lapses <- inforce_sop * lapse_rates

# ---- Reserving - Net premium reserves.
# find net premium first: expected inflows * net premium = expected payout
expected_inflows <- sum(discount_factors_advance * inforce_sop) 
expected_payout <- sum(discount_factor * deaths) * death_benefit
net_premium <- expected_payout / expected_inflows

# find net premium reserves:
# to cover years 1 to last year. ie available at start of each year
reserves <- rep(NA, term)
for (i in 1:term) {
  future_inflows <- sum(discount_factors_advance[i:term] * inforce_sop[i:term]) * net_premium 
  future_benefits <-  sum(discount_factor[i:term] * deaths[i:term]) * death_benefit
  reserves[i] <- (future_benefits - future_inflows)  
}

reserve_increase <- c(reserves[2:term], 0) - c(reserves[1:term])

# ---- profits
profits <- rep(NA, term) 

cash_flow <- inforce_sop * (rep(premium, term) - expenses - commission_percentages * premium) - death_benefit * deaths
interest <- ((cash_flow + death_benefit*deaths) + reserves) * interest_rates
profits <- cash_flow + interest - reserve_increase

# present value
profit <- sum(discount_factor * profits)

#return(profit)
sheet <- data.frame("year" = seq(1: term), 
                    "deaths" = deaths, "lapses" = lapses,
                    "premium" = rep(premium, term),
                    "commission" = commission_percentages * premium,
                    "expenses" = expenses,
                    "cash_flow" = cash_flow, 
                    "expected_payout" = death_benefit * deaths,
                    "interest" = interest, 
                    "reserve_increase" = reserve_increase,
                    "profit" = profits)

return(list("sheet" = sheet, "profit" = profit))
}

calculateProfit(200)$profit
