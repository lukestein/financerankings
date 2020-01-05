clear
import delimited using "rankings data import.csv", varnames(1) encoding("utf-8")
isid organization 

rename organization organization_str
encode organization_str, generate(organization)
drop organization_str
 
reshape long pubs, i(organization) j(year)
assert ~missing(pubs)

xtset organization year

tsegen trailingpubs = rowtotal(L(0/2).pubs)

egen rank = rank(trailingpubs), field by(year)

egen rank_unique = rank(-trailingpubs), unique by(year)
label var rank_unique "Rank"


compress
save rankingsdata, replace

export delimited using rankingsdata.csv, quote replace




gsort -year +rank

// Top ranked
browse organization year trailingpubs rank if (rank == 1)

// Schools of interest
browse organization year trailingpubs rank pubs if (organization == "Babson College":organization)
browse organization year trailingpubs rank pubs if (organization == "Arizona State University":organization)

// Rank achieved by number of trailing pubs
table year trailingpubs if inrange(trailingpubs, 1, 10) & (year>= 2000), c(min rank)

// Trailing pubs required to be in top X
table year rank_unique if inlist(rank_unique, 1, 5, 10, 25, 50, 100) & (year>= 2000), c(min trailingpubs)
