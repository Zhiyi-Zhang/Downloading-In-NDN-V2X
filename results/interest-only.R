# Read Raw Data
rawData <- readLines("basic.txt")
options(scipen=999)

# Extract Data Data
dataPattern <- "^\\+([.0-9]*).* < DATA for ([0-9]*)$"
dataData <- regmatches(rawData, gregexpr(dataPattern, rawData))
dataData <- dataData[grep(dataPattern, dataData)]
for (i in 1:length(dataData)) {
  dataData[i] <- sub(dataPattern, "\\1 \\2", dataData[i])
}

# Extract Interest Data
interestPattern <- "^\\+([.0-9]*).*Interest for ([0-9]*)$"
interestData <- regmatches(rawData, gregexpr(interestPattern, rawData))
interestData <- interestData[grep(interestPattern, interestData)]
for (i in 1:length(interestData)) {
  interestData[i] <- sub(interestPattern, "\\1 \\2", interestData[i])
}

# Extract Prefetch Interest Data
PreFetchInterestPattern <- "^\\+([.0-9]*).* > Pre-Fetch Interest for ([0-9]*)$"
PreFetchInterestData <- regmatches(rawData, gregexpr(PreFetchInterestPattern, rawData))
PreFetchInterestData <-PreFetchInterestData[grep(PreFetchInterestPattern, PreFetchInterestData)]
for (i in 1:length(PreFetchInterestData)) {
  PreFetchInterestData[i] <- sub(PreFetchInterestPattern, "\\1 \\2", PreFetchInterestData[i])
}
# duplicatedInterestNumber <- length(PreFetchInterestData)
# duplicatedInterestRatio <- duplicatedInterestNumber/(length(interestData) + duplicatedInterestNumber)

# Extract Recovery Interest Data
RecoveryInterestPattern <- "^\\+([.0-9]*).* > Recovery Interest for ([0-9]*)$"
RecoveryInterestData <- regmatches(rawData, gregexpr(RecoveryInterestPattern, rawData))
RecoveryInterestData <-RecoveryInterestData[grep(RecoveryInterestPattern, RecoveryInterestData)]
for (i in 1:length(RecoveryInterestData)) {
  RecoveryInterestData[i] <- sub(RecoveryInterestPattern, "\\1 \\2", RecoveryInterestData[i])
}

# Extract Dropped Data Data
DroppedPreFetchDataPattern <- "^\\+([.0-9]*).*< Pre.Fetch DATA..([0-9]*)..DROP.$"
DroppedPreFetchDataData <- regmatches(rawData, gregexpr(DroppedPreFetchDataPattern, rawData))
DroppedPreFetchDataData <-DroppedPreFetchDataData[grep(DroppedPreFetchDataPattern, DroppedPreFetchDataData)]
DroppedPreFetchDataNumber <- length(DroppedPreFetchDataData)
DroppedPreFetchDataRatio <- DroppedPreFetchDataNumber/(length(dataData) + DroppedPreFetchDataNumber)

# Extract Hop Data
hopcountPattern <- "^\\+([.0-9]*).*Hop count: ([0-9]*)$"
hopData <- regmatches(rawData, gregexpr(hopcountPattern, rawData))
hopData <- hopData[grep(hopcountPattern, hopData)]
for (i in 1:length(hopData)) {
  hopData[i] <- sub(hopcountPattern, "\\1 \\2", hopData[i])
}

# Calculate RTT
# df <- data.frame(index = numeric(length(dataData)),
#                  sending = numeric(length(dataData)),
#                  recieving = numeric(length(dataData)),
#                  rtt = numeric(length(dataData)),
#                  hopcount = numeric(length(dataData)),
#                  stringsAsFactors = FALSE)
# 
# for (i in 1:length(dataData)) {
#   item <- strsplit(as.character(dataData[i]), " ")
#   index <- as.numeric(item[[1]][2])
#   df$index[i] <- index
#   recieveTime <- as.numeric(item[[1]][1])
#   for (j in length(interestData):1) {
#     item2 <- strsplit(as.character(interestData[j]), " ")
#     index2 <- as.numeric(item2[[1]][2])
#     sendTime <- as.numeric(item2[[1]][1])
#     if (index2 - index == 0) {
#       df$sending[i] <- sendTime
#       df$recieving[i] <- recieveTime
#       df$rtt[i] <- (recieveTime*1000000000 - sendTime*1000000000)# - 214296000
#       break
#     }
#   }
#   for (j in length(RecoveryInterestData):1) {
#     item2 <- strsplit(as.character(RecoveryInterestData[j]), " ")
#     index2 <- as.numeric(item2[[1]][2])
#     sendTime <- as.numeric(item2[[1]][1])
#     if (index2 - index == 0) {
#       df$sending[i] <- sendTime
#       df$recieving[i] <- recieveTime
#       df$rtt[i] <- (recieveTime*1000000000 - sendTime*1000000000)# - 214296000
#       break
#     }
#   }
#   item3 <- strsplit(as.character(hopData[i]), " ")
#   df$hopcount[i] <- as.numeric(item3[[1]][2])
# }
# 
# # show plot
# #plot(df$rtt[1:nrow(df)], xlab="Data ID", ylab="Round-Trip Time")
# pdf("interest-only-hop-count.pdf",width=7,height=4) 
# par(mar=c(4,4,0,0)+0.1)
# plot(df$hopcount[1:nrow(df)], 
#      xlab="Target Data ID", ylab="Hop Number", 
#      ylim = c(1, 5),
#      pch = 1, cex.lab=1.5, cex.axis=1.5, cex.main=1.5, cex.sub=1.5)
# dev.off()
# rttsum <- summary(df$rtt[1:100])

# packets received per sencod
scale <- 0.5
table_row <- 60/scale
df2 <- data.frame(second = numeric(table_row),
                  packetNum = numeric(table_row),
                  stringsAsFactors = FALSE)
for (i in 1:table_row) {
  df2$second[i] <- i*scale
  counter <- 0
  for (j in 1:length(dataData)) {
    item <- strsplit(as.character(dataData[j]), " ")
    recieveTime <- as.numeric(item[[1]][1])
    if (recieveTime <= i*scale && recieveTime > (i - 1)*scale ) {
      counter <- counter + 1
    }
  }
  df2$packetNum[i] <- counter
}
pdf("interest-only-downloading.pdf",width=6,height=3.5)
par(mar=c(2,2,0,0)+0.2)
plot(df2$second[1:table_row], df2$packetNum[1:table_row]*(1/scale), 
     xlab="Simulation Time (s)", ylab="Downloading (pkts/s)",
     ylim = c(0, 40),
     type="l", col="blue", cex.lab=1.5, cex.axis=1.5, cex.main=1.5, cex.sub=1.5)
dev.off()


# calculate how long it take to recovery all the pre-fetched Data packets
# deltaTime <- function(startIndex, endIndex) {
#   sendingTime <- 0
#   for (i in 1:length(RecoveryInterestData)) {
#     item <- strsplit(as.character(RecoveryInterestData[i]), " ")
#     index <- as.numeric(item[[1]][2])
#     sendTime <- as.numeric(item[[1]][1])
#     if (index >= startIndex && index <= endIndex) {
#       sendingTime <- sendTime
#       break
#     }
#   }
#   totalTime <- 0
#   count <- 0
#   for (i in 1:length(dataData)) {
#     item <- strsplit(as.character(dataData[i]), " ")
#     index <- as.numeric(item[[1]][2])
#     recieveTime <- as.numeric(item[[1]][1])
#     if (index >= startIndex && index <= endIndex) {
#       totalTime <- totalTime + recieveTime
#       count <- count + 1
#     }
#   }
#   return(totalTime/count - sendingTime)
# }
# 
# s1 <- 0
# s2 <- 0
# s3 <- 0
# s4 <- 0
# s5 <- 0
# e1 <- 0
# e2 <- 0
# e3 <- 0
# e4 <- 0
# e5 <- 0
# lastIndex <- 0
# 
# for (i in 1:length(RecoveryInterestData)) {
#   item <- strsplit(as.character(RecoveryInterestData[i]), " ")
#   index <- as.numeric(item[[1]][2])
#   
#   if (i == 1) {
#     s1 <- index
#   }
#   
#   if (index == lastIndex + 1 && lastIndex != 0) {
#     # do nothing
#   }
#   else {
#     if (s2 == 0  && lastIndex != 0) {
#       s2 <- index
#       e1 <- lastIndex
#     }
#     else if (s3 == 0  && lastIndex != 0) {
#       s3 <- index
#       e2 <- lastIndex
#     }
#     else if (s4 == 0  && lastIndex != 0) {
#       s4 <- index
#       e3 <- lastIndex
#     }
#     else if (s5 == 0  && lastIndex != 0) {
#       s5 <- index
#       e4 <- lastIndex
#     }
#   }
#   
#   if (i == length(RecoveryInterestData)) {
#     e5 <- index
#   }
#   lastIndex <- index
# }
# 
# 
# deltaTimeResult <- c(
#   deltaTime(startIndex = s1, endIndex = e1),
#   deltaTime(startIndex = s2, endIndex = e2),
#   deltaTime(startIndex = s3, endIndex = e3),
#   deltaTime(startIndex = s4, endIndex = e4),
#   deltaTime(startIndex = s5, endIndex = e5)
# )
# summary(deltaTimeResult)
