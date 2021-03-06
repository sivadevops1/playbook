## ----echo=FALSE----------------------------------------------------------
#########################################################################
# Copyright (C) 2011-2014 Guy Yollin                                    #
# License: http://www.gnu.org/licenses/gpl.html GPL version 2 or higher #
#########################################################################

## ----Environment set-up-------------------------------------------------------
library(rulesNtrades)
library(dataNindicators)
clean.all.portfolios()
rm(list =ls())
load("data/temp.rda")

source("R/longs.R")
source("R/shorts.R")
source("R/graph.R")

## ----Prepare the data----------------------------------------------------
myWidth <- 9
#data("SBIN")
#d <- SBIN["2016-03::2016-05"]
d <- NIFTY["2016-05-02::2016-05-10"]
d  <- to.minutes5(d,indexAt = 'startof')
colnames(d) <- c("Open","High","Low","Close","Volume")
d1 <- flow(d)

d2 <- rollapply(d1,
                width = myWidth,
                FUN = flowDex,
                fFUN = sum,
                by.column = FALSE,
                align = "right")
res <- merge.xts(d1,d2)
res <- merge.xts(d,res,join = "inner")
res <- na.trim(res)

## ----Set all the parameters     ----------------------------------------
parms <- tradeParms()
parms$longTrades  <- TRUE
parms$shortTrades <- TRUE
parms$sameDayFlag <- TRUE

parms$instrument <- "NIFTY"
parms$qty        <- 300
#
parms$pctFlag    <- FALSE
#
parms$slpFlag    <- FALSE
parms$slpAmt     <- 9
# 
parms$pbFlag     <- FALSE
parms$pbAmt      <- 15
parms$pbQty      <- 3000
parms$pbRunQty   <- 3000
#
parms$trlFlag     <- FALSE
parms$trlInitAmt  <- 12
parms$trlIncrAmt  <- 6
parms$trlSlpAmt   <- NA

parms$intraday    <- TRUE
parms$idStartTime <- "09:30"
parms$idEndTime   <- "15:15"


## ----Create the default portfolio----------------------------------------
#if( exists("pf") && is.portfolio(pf)) {delete.portfolio(pf = "default") }
pf <- "default"
delete.portfolio()
pf <- portfolio(pf = "default")

## ----backtest the strategies---------------------------------------------
options(warn = 2)

backtest(pf,res,parms,
         longE = longEntry,
         longX = longExit,
         shortE = shortEntry,
         shortX = shortExit,
         calcLimits = calcLimits
         )
## ----Get the trades  ----------------------------------------------------
t  <- get.trades(pf)
st <- t[t$direction == "SHORT",]
lt <- t[t$direction == "LONG",]
wt <- t[t$netP > 0,]
loosingT <- t[t$netP <0,]

## ----Get the stats   ----------------------------------------------------
tStats  <- stats.trades(t)
stStats <- stats.trades(st)
ltStats <- stats.trades(lt)
cbind(tStats,stStats,ltStats)
t %>% group_by(direction,openReason,closeReason) %>% summarise(Profit = sum(netP))

## ----make blotter  ----------------------------------------------------
make.blotter(pf)

## ----Graph the trades  ----------------------------------------------------
#myGraph(pf,prices = res[,1:4],file = "temp4.pdf",by = "quarters")

myGraph(pf,
        prices = res[,1:4],
        parms = parms,
        #file = "temp5.pdf",
        by = "quarters")
